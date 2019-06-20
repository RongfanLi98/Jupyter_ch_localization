#!/bin/bash
# python version == 2.7 or > 3.3 and need to run under conda env
# if jupyter have been installed, the script will still ask for new password
# sudo apt-get update
# sudo apt-get upgrade

apt_install(){
    for i in $*
    do
        echo $i
        sudo apt install $i
    done
}
conda_install(){
    for i in $*
    do
        echo $i
        conda install $i
    done
}
config_jupyter(){
    jupyter notebook --generate-config
    ehco 'pw set:welcome1'
    jupyter notebook password
    path=${HOME}'/.jupyter/jupyter_notebook_config.py'
    # path=${HOME}'/.jupyter/ju.py'
    # change rows
    sed -i "/c.NotebookApp.ip/c c.NotebookApp.ip = '0.0.0.0'" $path
    sed -i "/c.NotebookApp.open_browser/c c.NotebookApp.open_browser = False" $path
    sed -i "/c.NotebookApp.notebook_dir/c c.NotebookApp.notebook_dir = '$notebook_dir' " $path
}
config_latex(){
    echo 'checking font family...'
    txt=`fc-list :lang=zh`
    font_one='AR PL UMing CN'
    font_two='Noto Sans CJK SC'
    if [[ $txt == *$font_one* ]]
    then
        echo 'AR PL UMing CN found'
        font='AR PL UMing CN'
    elif [[ $txt == *$font_two* ]]
    then
        echo 'Noto Sans CJK SC found'
        font='Noto Sans CJK SC'
    else
        exit
    fi

    echo 'import sys' > python_root_path.py
    echo 'from distutils.sysconfig import get_python_lib; print (get_python_lib())' >> python_root_path.py
    lib_path=`python python_root_path.py`
    echo $lib_path
    template_path=${lib_path}'/nbconvert/templates/latex/'
    # article=${template_path}'article_d.tplx'
    # base=${template_path}'base_d.tplx'
    article=${template_path}'article.tplx'
    base=${template_path}'base.tplx'
    # if it is necessary to check the existent content to avoid duplicate?
    # add setting to article, and delete ascii_only from base
    sed -i "/\\documentclass\[11pt\]{article}/a \\\\\usepackage{indentfirst}\n\\\\usepackage{xeCJK}\n\\\\setCJKmainfont{${font}}" $article
    sed -i "s/ | ascii_only//" $base
    rm python_root_path.py
}
# check if the env had been activated

if [ $# -lt 1 ]
then 
    echo 'add a conda environment in command line, like bash test.sh testenv'
    exit
fi

source activate $1
conda info -e
python --version

# choose notebook dir
notebook_dir=${HOME}'/jupyter-chinese'
echo "notebook dir is:${HOME}"

# cp ./msyh.ttf ./msyh.ttf
conda install pandoc jupyter nbconvert
apt_install texlive-xetex latex-cjk-chinese texlive-fonts-recommended 
config_jupyterl
config_latex
