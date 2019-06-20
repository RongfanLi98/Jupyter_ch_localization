## 问题
Jupyter Notebook在有些情况下，无法显示中文界面。

## 环境

* Ubuntu 18.04 LTS
* python 3.7.2
* ipython 6.5.0
* jupyter 4.4.0
* pandoc 2.2.3.2
* nbconvert 5.3.1

## 解决方案

### 解决思路
Jupyter自身带有internationalization(国际化，缩写i18n)，所以只需要将翻译文件放到Jupyter指定的位置就可以了。

### 解决过程

1. 查找官方信息  
在jupyter的官方GitHub上可以看到[官方i18n手册](https://github.com/jupyter/notebook/blob/master/notebook/i18n/README.md)和[官方翻译文件](https://github.com/jupyter/notebook/tree/master/notebook/i18n/zh_CN/LC_MESSAGES)，这两个对于如何解决问题至关重要。下面按照官方的思路进行配置。  
其中官方三个翻译文件，分别的内容如下：
    * nbjs.po--JavaScript strings and dialogs, which contain much of the visible user interface for Jupyter notebook.
    * nbui.po--User interface strings, as extracted from the Jinja2 templates in notebook/templates/*.html
    * notebook.po-- Console and startup messages, basically anything that is produced by Python code
2. 找到配置的文件夹  
    首先需要找到翻译文件放在哪里。利用下面的shell脚本，可以输出python库路径
    ```shell
    echo 'import sys' > python_lib_path.py
    echo 'from distutils.sysconfig import get_python_lib; print (get_python_lib())' >> python_lib_path.py
    lib_path=`python python_lib_path.py`
    ```
    一般`lib_path == /opt/conda/lib/python3.7/site-packages`。然后就可以确定i18n路径`${lib_path}/notebook/i18n`。
3. 准备翻译文件  
    .po文件中内容类似下面的内容
    ```
    #: notebook/static/base/js/dialog.js:180
    msgid "Edit the metadata"
    msgstr "编辑元数据"

    #: notebook/static/base/js/dialog.js:202
    msgid "Edit Notebook Metadata"
    msgstr "编辑界面元数据"
    ```
    所以可以很容易理解地进行自己的翻译工作。 

    本来按照官方手册，是由pot转化成的po，再编译成其他格式，但是官网上给出了已经翻译了大半的内容，就不需要自己再进行第一步编译了。  

    将翻译文件置于`${i18n_path}/zh_CN/LC_MESSAGES`下，然后在`${i18n_path}`目录下执行以下命令。**注意，一定要在`${i18n_path}`目录下**，因为这些命令依赖的一些配置在这个文件夹下才有。  
    ```shell
    pybabel compile -D notebook -f -l zh_CN -i zh_CN/LC_MESSAGES/notebook.po -o zh_CN/LC_MESSAGES/notebook.mo
    pybabel compile -D nbui -f -l zh_CN -i zh_CN/LC_MESSAGES/nbui.po -o zh_CN/LC_MESSAGES/nbui.mo
    # po2json -p -F -f jed1.x -d nbjs zh_CN/LC_MESSAGES/nbjs.po zh_CN/LC_MESSAGES/nbjs.json
    ```  
    最终生成的文件就可以被Jupyter理解了。  

4. 待解决的问题  

1. 插件系统，即jupyter_contrib_nbextensions，的安装导致了中文的不全面。

2. nbjs.po编译json文件的时候，结果是
    ```
    "Stop the Jupyter server": [
            null,
            "关闭Jupyter服务器"
         ],
    ```
    而正确的格式应该是
    ```
    "Stop the Jupyter server": [
            "关闭Jupyter服务器"
         ],
    ```
    所以目前的js的中文化全部是在json文件上直接更改的。
    ```
    # po2json -p -F -f jed1.x -d nbjs zh_CN/LC_MESSAGES/nbjs.po zh_CN/LC_MESSAGES/nbjs.json
    ```
    这个命令是官方建议的命令。  
    目前想到的还没实施的解决方案是，用其他途径来编译这个文件。