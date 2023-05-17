---
title: Deploy my resume html page to cloudflare
date: "2022-12-13"
tags:
  - cloudflare-pages
  - cloudflare
  - resume
---

I will show you how i create my resume page and deploy to cloudflare pages. Here is my live resume <https://resume.isaacyip.com/>.

<!--more-->

1. Create a repo with your resume html page on github. You can fork my repo [here](https://github.com/yip102011/my_resume)
2. Buy a domain name in cloudflare.
3. Once you bought a domain, login cloudflare, goto `Pages > Create project > Connect to Git`
   ![](cloudflare_pages_create_project.png)
4. Add your github account and select your resume repository.
   ![](cloudflare_pages_login.png)
5. since cloudflare only take `index.html` as default page, we will rename our resume html file to `index.html` in build command.
   ![](cloudflare_pages_setup_build.png)
6. When the build success you can see your website on the url. Then click `Continue to project`.
   ![](cloudflare_pages_build_success.png)
7. Setup your domain name for the page.
   ![](cloudflare_pages_set_domain.png)
   ![](cloudflare_pages_set_domain_2.png)
   ![](cloudflare_pages_set_domain_3.png)
8. Wait a few minutes, until the domain turn to Active, then you can access your resume page with your domain
   ![](cloudflare_pages_set_domain_4.png)