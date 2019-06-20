### Problems

The PDF printed by jupyter notebook can't display Chinese properly or it just can't print PDF. 

### Environments

* Ubuntu 18.04 LTS
* python 3.7.2
* ipython 6.5.0
* jupyter 4.4.0
* pandoc 2.2.3.2
* nbconvert 5.3.1

### Solution

1. Can't print PDF

   IF you can't print PDF, please follow the error message. Mostly there are some dependencies that haven't installed yet. Here are some examples.

   - Pandoc

     Error message: nbconvert failed: Pandoc wasn't found. Please check that pandoc is installed

     Command：```conda install pandoc```

   - xelatex

     Error message: nbconvert failed: xelatex not found on PATH, if you have not installed xelatex you may need to do so. Find further instructions at https://nbconvert.readthedocs.io/en/latest/install.html#installing-tex.

     Command：```sudo apt-get install texlive-xetex```

     Note the command difference between linux and windows, mac OS. And the xelatex is not one of the python packages, so it can't be installed by conda or pip. There are many dependencies and fonts that nbconvert need in the xelatex. 

   - If there is still some problem...

     I met some other problem maybe you won't meet, but I still write here. 

     - Could not map source abbreviation for ecrm1095.
     - LaTeX Error: File `caption.sty' not found

     It's because it lack some files that latex need, but I am not sure which package should I install. I tried some, luckily it works.

     I executed the following command:

     ```shell
     sudo apt install texlive-fonts-recommended texlive-latex-recommended latex-cjk-chinese
     ```

     If you don't know what to install, try this command. 

     ```shell
     apt-cache search caption | grep tex
     ```

     And you will get some prompts about what to install. You can change 'caption'  to what you need. 
     
     ```shell
     texlive-latex-recommended - TeX Live: LaTeX recommended packages
     texlive-lang-japanese - TeX Live: Japanese
     texlive-latex-extra - TeX Live: LaTeX additional packages
     texlive-pictures - TeX Live: Graphics, pictures, diagrams
     ```

     Finally, if your enough disk and you don't want to bother, try ```install texlive-full```.

2. PDF can't display Chinese content

   - Reason: the ipython call pandoc, and the pandoc call xetex, but there is some thing wrong with latex compiler. Because the markdown paragraphs must be compiled by latex compiler so that the latex file can be processed by other programs. 

   - Query process

     1. Querying the [ texlive official document ](http://tug.org/texlive/doc.html). There is [Chinese version](http://tug.org/texlive/doc/texlive-zh-cn/). 
     2. Found the [xetex official website](http://tug.org/xetex/). 
     3. Found the XeTeX [package page](https://ctan.org/pkg/xecjk). 
     4. Searching for package with keyword ‘cjk’, and I found xecjk. There is tutorial  with exhaustive configuration about article.tplx included. 

   - Modify templates

     1. Check local Chinese fonts by```fc-list :lang=zh```, mind the blank. 

     2. Open the path```~/anaconda3/lib/python3.7/site-packages/nbconvert/templates/latex```

     3. Modify the article.tplx, find the docclass and enter your font setting. 

     4. Insert some code into preamble section like this:

        ```
        ((* block docclass *))
        \documentclass[11pt]{article}
        \usepackage{xeCJK}
        \setCJKmainfont{AR PL UMing CN}
        ```

        Note that the font name is not the same name of the file. For example, I get a ttc file like this ```/usr/share/fonts/truetype/arphic/uming.ttc: AR PL UMing CN:style=Light```, the font name is 'AR PL UMing CN', but the name of the file is 'uming.ttc'. 

     5. I tried to change documentclass from 'article' into 'ctexart', but there is no 'ctexart.cls' on my disk. You can download one and it will work too. 

3. PDF title can't display Chinese

   Find 'base.tplx' under the same directory where 'article.tplx' exists. And there must be such a line here. 

   ```
   ((* block title *))\title{((( resources.metadata.name | ascii_only | escape_latex )))}((* endblock title *))
   ```

   Just delete ```ascii_only```, and it will work well. 

4. PDF has wrong indentation

   The latex compiler only support markdown grammar that there must be blank line before and after a paragraph, so that it will indent automatically. 

   But the first paragraph in every notebook cell still can't indent properly, it's because the latex set it as default. You can insert ```\usepackage{indentfirst}``` into preamble section to solve it. 

   And there is some other troubles with the latex compiler, so you can refer to the documents that describe the grammar in order to write the standard markdown content, when you met some Inexplicable questions. 

### References

https://www.linuxidc.com/Linux/2015-07/120653.htm

http://blog.jqian.net/post/xelatex.html

https://nova.moe/config-chinese-latex-env-on-fedora/

https://nova.moe/fix-jupyter-export-pdf-CJK-display-problem/

http://blog.sina.com.cn/s/blog_487bb6210101ap8r.html

https://github.com/jupyter/notebook/issues/2848