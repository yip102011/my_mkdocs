---
title: Error Cheat Sheet
tags:
  - error
  - cheat-sheet
slug: error-cheat-sheet

---

# Errors

## The configured user limit (128) on the number of inotify instances has been reached

> Unhandled exception. System.IO.IOException: The configured user limit (128) on the number of inotify instances has been reached, or the per-process limit on the number of open file descriptors has been reached.

this error occurred when deploy too mush host application  
solution below

```bash
echo "fs.inotify.max_user_instances = 1024" | sudo tee /etc/sysctl.d/fs__inotify__max_user_instances.conf
sudo sysctl --system
sysctl fs.inotify.max_user_instances
```
