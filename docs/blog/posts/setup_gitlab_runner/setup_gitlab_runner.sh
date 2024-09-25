#!/bin/bash
if [[ ! $(id -u) == 0 ]]; then
    echo "This script must be run with sudo"
    exit 1
fi

##=============================================
read -p "What is your gitlab runner registration token?: " REGISTRATION_TOKEN

read -p "What is your gitlab host? (no port, example: 192.168.0.11): " GITLAB_HOST
read -p "What is your gitlab port? [default: 443]: " GITLAB_PORT
GITLAB_PORT=${GITLAB_PORT:-'443'}
GITLAB_URL="https://${GITLAB_HOST}:${GITLAB_PORT}/"

read -p "What is your registry host? (no port, example: 192.168.0.12): " HARBOR_HOST
read -p "What is your registry port? [default: 443]: " HARBOR_PORT
HARBOR_PORT=${HARBOR_PORT:-'443'}

read -p "What is your registry port? [/srv/gitlab-runner]: " DEPLOY_FOLDER
DEPLOY_FOLDER=${DEPLOY_FOLDER:-'/srv/gitlab-runner'}

# REGISTRATION_TOKEN="xxxxxxxxxxxxx"

# GITLAB_HOST=192.168.0.11
# GITLAB_PORT=443
# GITLAB_URL="https://${GITLAB_HOST}:${GITLAB_PORT}/"

# HARBOR_HOST=192.168.0.12
# HARBOR_PORT=443

# DEPLOY_FOLDER=/srv/gitlab-runner

##=============================================

mkdir -p ${DEPLOY_FOLDER}
mkdir -p ${DEPLOY_FOLDER}/config
mkdir -p ${DEPLOY_FOLDER}/config/certs
cd ${DEPLOY_FOLDER}

# download gitlab server certificate
openssl s_client -showcerts -connect ${GITLAB_HOST}:${GITLAB_PORT} </dev/null 2>/dev/null | openssl x509 -outform PEM >${DEPLOY_FOLDER}/config/certs/${GITLAB_HOST}.crt

# download harbor server certificate
openssl s_client -showcerts -connect ${HARBOR_HOST}:${HARBOR_PORT} </dev/null 2>/dev/null | openssl x509 -outform PEM >${DEPLOY_FOLDER}/${HARBOR_HOST}.crt

docker run --rm -v ${DEPLOY_FOLDER}/config:/etc/gitlab-runner/ docker.io/gitlab/gitlab-runner:v15.8.2 register \
  --non-interactive \
  --tag-list="dind-runner" \
  --name="dind-runner" \
  --executor "docker" \
  --docker-image "docker:23" \
  --docker-tlsverify="false" \
  --run-untagged="true" \
  --custom_build_dir-enabled \
  --builds-dir="/builds" \
  --docker-volumes="/builds:/builds" \
  --env='GIT_CLONE_PATH=$CI_BUILDS_DIR/$CI_CONCURRENT_ID/$CI_PROJECT_NAME' \
  --cache-dir="/cache" \
  --docker-volumes="/cache:/cache" \
  --docker-volumes="/var/run/docker.sock:/var/run/docker.sock" \
  --docker-volumes="/etc/docker/certs.d:/etc/docker/certs.d" \
  --url="${GITLAB_URL}" \
  --registration-token="${REGISTRATION_TOKEN}"

docker wait register

# update concurrent to 10
sudo sed -i 's/concurrent.*/concurrent = 10/' ${DEPLOY_FOLDER}/config/config.toml

echo "
services:
  dind:
    container_name: dind
    image: docker:23-dind
    restart: always
    privileged: true
    environment:
      # force docker deamon to disable TLS
      DOCKER_TLS_CERTDIR: ''
    command:
      - --storage-driver=overlay2
    networks:
      - gitlab-runner
    volumes:
      - ${DEPLOY_FOLDER}/${HARBOR_HOST}.crt:/etc/docker/certs.d/${HARBOR_HOST}/ca.crt
  runner:
    container_name: runner
    restart: always
    image: docker.io/gitlab/gitlab-runner:v15.8.2
    depends_on:
      - dind
    environment:
      - DOCKER_HOST=tcp://dind:2375
    volumes:
      - ${DEPLOY_FOLDER}/config:/etc/gitlab-runner
    networks:
      - gitlab-runner
networks:
  gitlab-runner: {}
" >${DEPLOY_FOLDER}/docker-compose.yml

cd ${DEPLOY_FOLDER}
docker compose up -d --wait

(crontab -l && echo "0 0 1 * *  docker exec dind docker system prune --all --force --filter 'until=168h'") | crontab -
(crontab -l && echo "0 0 1 * *  docker exec dind docker system prune --all --force --volumes") | crontab -
crontab -l
