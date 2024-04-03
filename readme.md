## install

```bash
pip install mkdocs-material
```

## init project

```
mkdocs new .
```

## run server

```bash
# in cli
pip install -r requirements.txt
mkdocs serve
# in docker (linux)
docker run --rm -it -v ${PWD}:/docs squidfunk/mkdocs-material:9.5.17 new .
# in docker (windows cmd)
docker run --rm -it -p 8000:8000 -v "%cd%":/docs squidfunk/mkdocs-material:9.5.17
# in docker (windows powershell)
docker run --rm -it -v ${PWD}:/docs squidfunk/mkdocs-material:9.5.17 build
```

## build site(static files)
```bash
mkdocs build
```