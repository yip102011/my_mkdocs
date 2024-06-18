---
title: Disable CORS on chrome
date: 2024-06-18
tags:
  - chrome
  - cors
slug: disable-cors-on-chrome

---

When develop web api on local PC, you may meet CORS, but you don't config server to allow CORS. Here is how to disalbe it on chrome.

<!-- more -->

## Disable web security

You can use command to open chrome and add option `--disable-web-security` 
```batch
"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" --disable-web-security
```
or even better, create shortcut for it.

## other user
Additionally, you can add option `user-data-dir` to change user dir to sperate cookie. so you can login as another user.
```batch
"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" --user-data-dir="C:/chrome_dev_session" --disable-web-security
```
