---
title: Export markdown to docx 
date: 2022-04-25
tags:
  - kubernetes
  - ingress-nginx
  - tls
slug: export-markdown-to-docx

---

How to export markdown file to word docx file 

<!-- more -->

# Export markdown to word docx file

## Install Pandoc

Install pandoc from https://pandoc.org/installing.html

## modify style

1. export default style docx, open it.

   ```shell
   pandoc -o custom-reference.docx --print-default-data-file reference.docx
   ```

2. modify header style
   ![](markdown_to_docx/docx_h1_style.png)

3. modify table style

   Select table, click `Table Design` on top bar.  
   Select `Table Normal`
   ![](markdown_to_docx/docx_table_style.png)
   ![](markdown_to_docx/docx_table_style_2.png)

4. save docx file

## Export markdown file to docx file

4. config vscode settings  
   add `--reference-doc="custom-reference.docx"` to "Docx Opt String"
   ![](markdown_to_docx/vscode_settings.png)

5. exoprt markdown to docx file
   ![](vscode_export.png)
