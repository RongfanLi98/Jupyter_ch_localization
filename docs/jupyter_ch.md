### 问题

jupyter notebook打印的pdf，无法正常显示中文。

### 环境

* Ubuntu 18.04 LTS
* python 3.7.2
* ipython 6.5.0
* jupyter 4.4.0
* pandoc 2.2.3.2
* nbconvert 5.3.1

### 解决方案

1. 无法打印

    原因是依赖不全，按照错误提示下载好就可以
    
    * 下载pandoc

        nbconvert failed: Pandoc wasn't found. Please check that pandoc is installed

        解决：```conda install pandoc```

    * 下载xelatex

        nbconvert failed: xelatex not found on PATH, if you have not installed xelatex you may need to do so. Find further instructions at https://nbconvert.readthedocs.io/en/latest/install.html#installing-tex.

        解决：```sudo apt-get install texlive-xetex```

        注意linux和windows，mac不同，这不是python的包，详见上面的链接

        这个包包含了nbconvert需要的字体和包依赖

2. pdf内容无法显示中文

    * 原因：latex编译器的问题，ipython调用pandoc，再调用xetex的库，中间在字体的问题上出现了问题
    * 查询过程
        1. 查阅texlive文档http://tug.org/texlive/doc.html，下面有提供中文版
        2. 找到xetex官网：http://tug.org/xetex/
        3. 找到XeTeX package page ： https://ctan.org/pkg/xecjk
        4. 搜索包cjk，发现了xecjk，附使用教程，有全面的article.tplx配置方法

    * 正式修改模板
        1. 查看本地中文字体，fc-list :lang=zh，注意空格
        2. 路径：```~/anaconda3/lib/python3.7/site-packages/nbconvert/templates/latex```
        3. 修改文件article.tplx，往这下面的docclass里面写入字体设置
        4. ~~article 改成ctexart %\documentclass[11pt]{ctexart}，发现ctexart.cls缺失，可以考虑去下载一个~~
        5. 在导言区写入\setCJKmainfont{NotoSerifCJK-Regular}发现无法找到这个字体，结果是因为名字写错，比如/usr/share/fonts/truetype/arphic/uming.ttc: AR PL UMing CN:style=Light，名字是AR PL UMing CN，而不是前面的uming.ttc
        6. 最终的代码
            ```
            ((* block docclass *))
            \documentclass[11pt]{article}
            \usepackage{indentfirst}
            ​\usepackage{xeCJK}\setCJKmainfont{AR PL UMing CN}​
            ```

3. pdf标题无法显示中文
    * 参考:https://github.com/jupyter/notebook/issues/2848
    * 修改和article.tplx同文件夹的base.tplx,找到
        ```
        ((* block title *))\title{((( resources.metadata.name | ascii_only | escape_latex )))}((* endblock title *))
        ```
        这是title的生成方式,将ascii_only删掉即可

4. pdf缩进混乱

    参考:http://xianbai.me/learn-md/article/syntax/paragraphs-and-line-breaks.html

    段落的前后必须是空行，会自动缩进，段末用两个空格+enter代表换行

    但是每个cell的第一行，还是无法缩进，这是latex的默认写法

    要强制缩进需要这导言区加上\usepackage{indentfirst}

5. pdf无法正常显示列表
    要把列表当成段落来看，前后要空行
    两个pdf的显示问题都是markdown转latex的时候出现的问题，主要是markdown的标准不同导致的预期不同

### 服务器测试
1. 创建conda环境：conda create --name 
2. jupyter-chinese-test python=3.7
3. 安装必要的包：jupyter，pandoc等
4. 配置远程登录
    * 生成配置文件：```jupyter notebook --generate-config```

    * 设置密码：```jupyter notebook password welcome1```

    * 修改配置文件：```home/USERNAME/.jupyter/jupyter_notebook_config.py```

        ```python
        # c.NotebookApp.ip='*'  #出错
        c.NotebookApp.ip='0.0.0.0'     # 设置监听全部ip地址
        c.NotebookApp.password = 'welcome1' # 之前设置的密码
        c.NotebookApp.open_browser = False
        c.NotebookApp.notebook_dir = '~/jupyter-chinese'
        ```

5. 安装xelatex：```sudo apt-get install texlive-xetex```

6. 新问题：Could not map source abbreviation for ecrm1095.

    原因：缺失字体

    ```sudo apt install texlive-fonts-recommended```

7. 新问题：LaTeX Error: File `caption.sty' not found

    原因：Use of unavailable package

    ```sudo apt-get -y install texlive-latex-recommended```

8. 但是仍然缺失新的sty

    在sudo apt-get install texlive texlive-math-extra texlive-latex-base texlive-latex-extra texlive-latex-recommended texlive-pictures texlive-science texlive-bibtex-extra texlive-common latex-beamer中筛选一些包，比如caption或者cjk缺失的时候，用
    ```shell
    apt-cache search caption | grep tex
    apt-cache search cjk | grep tex
    
    sudo apt-get install latex-cjk-chinese
    ```

9. 如果硬盘空间足够，可以直接install texlive-full,可解决基本上全部字体问题

10. 重复之前的中文配置，下面是一些不一样的地方

   * 路径是:```~/anaconda3/envs/jupyter-chinese-test/lib/python3.7/site-packages/nbconvert/templates/latex```
   * 又缺失了cjk的某sty，```apt-cache search cjk | grep tex```，找到大概的包名
   * 安装latex-cjk-chinese

11. 成功

### 自动化脚本

见bash脚本ch.sh

### 参考

https://www.linuxidc.com/Linux/2015-07/120653.htm
http://blog.jqian.net/post/xelatex.html
https://nova.moe/config-chinese-latex-env-on-fedora/
https://nova.moe/fix-jupyter-export-pdf-CJK-display-problem/
http://blog.sina.com.cn/s/blog_487bb6210101ap8r.html