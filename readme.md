## run server

```bash
# in cli
pip install -r requirements.txt
# in linux
mkdocs serve
# in docker (linux)____
docker run --rm -it -p 8000:8000 -v ${PWD}:/docs squidfunk/mkdocs-material:9.5.17
# in docker (windows cmd)
docker run --rm -it -p 8000:8000 -v "%cd%":/docs squidfunk/mkdocs-material:9.5.17
```

## build site(static files)
```bash
mkdocs build
```