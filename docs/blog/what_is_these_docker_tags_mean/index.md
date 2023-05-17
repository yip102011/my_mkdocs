---
title: what is these docker tags mean (bullseye, slim, alpine, jammy)?
date: "2023-01-26"
tags:
  - docker
  - docker-tag
aliases:
  - what-is-these-docker-tags-mean-bullseye-slim-alpine-jammy?
---

When first time seeing all this docker tag, i am very confused about what is these tag and which should i pick.  
Here i write down some tag that i know.

<!--more-->

Most of these tag represent different versions of linux such as debian, ubuntu, alpine.

## Alpine

Alpine is a extremely small size of linux that is only about 7 MB. You can see their about page [here](https://www.alpinelinux.org/about/).

## Debian and Ubuntu

Debian and Ubuntu use diff code name for diff os versions, you can see full code name here : [Debian](https://wiki.debian.org/), [Ubuntu](https://wiki.ubuntu.com/Releases)

### Debian code name

| os version | code name |
| ---------- | --------- |
| 11         | bullseye  |
| 10         | buster    |
| 9          | stretch   |
| 8          | jessie    |

### slim (slimmer)

`slim` is a smaller size of Debian Linux, it removed some packages normally not necessary within containers.  
It must come with one of debian release code like `:bullseye-slim`  
You can see description in dockerhub https://hub.docker.com/_/debian  
Size different here:

```
REPOSITORY   TAG             IMAGE ID       SIZE
debian       bullseye-slim   9f61210833de   80.5MB
debian       bullseye        5c8936e57a38   124MB
```

### Ubuntu code name

| os version       | code name |
| ---------------- | --------- |
| Ubuntu 22.04 LTS | jammy     |
| Ubuntu 20.04 LTS | focal     |
| Ubuntu 18.04 LTS | bionic    |
| Ubuntu 16.04 LTS | xenial    |
| Ubuntu 14.04 LTS | trusty    |

## rc (Release Candidates)

`rc` is a pre-release version that is not stable yet but close to release.

## ltsc (Long Term Servicing Channel)

`ltsc` means stable version of windows server, you can see it on [dotnet image](https://hub.docker.com/_/microsoft-dotnet-runtime/)
