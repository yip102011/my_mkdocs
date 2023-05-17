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
mkdocs serve
# OR
# in docker (linux)
docker run --rm -it -v ${PWD}:/docs squidfunk/mkdocs-material new .
# OR
# in docker (windows)
docker run --rm -it -p 8000:8000 -v "%cd%":/docs squidfunk/mkdocs-material
```

## build site(static files)
```bash
mkdocs build
```