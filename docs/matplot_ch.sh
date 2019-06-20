#!/bin/bash
# python version == 2.7 or > 3.3 and need to run under conda env
# root privilege and under root path

# 默认字体和shell是在同一文件夹下

# prepare fonts

sudo apt-get install -y fontconfig
mkdir /usr/share/fonts/chinese
cp ./msyh.ttf /usr/share/fonts/chinese
cp ./simhei.ttf /usr/share/fonts/chinese
cd /usr/share/fonts/chinese
sudo mkfontscale
sudo mkfontdir
fc-cache

# get font path

if [ $# -lt 1 ]
then 
    echo 'add a conda environment in command line, like bash test.sh testenv'
    exit
fi

source activate $1

echo 'import matplotlib' > font_path.py
echo 'import os' >> font_path.py
echo 'from matplotlib.font_manager import fontManager' >> font_path.py
echo "print(os.path.dirname(fontManager.defaultFont['ttf']))" >> font_path.py
font_path=`python font_path.py`
# echo $font_path

cp /usr/share/fonts/chinese/simhei.ttf $font_path
cp /usr/share/fonts/chinese/msyh.ttf $font_path

echo 'import matplotlib' > font_path.py
echo 'print(matplotlib.matplotlib_fname())' >> font_path.py
setting_path=`python font_path.py`
echo $setting_path
rm font_path.py

# change setting

sed -i "s/# font.family/font.family/" $setting_path
sed -i "s/# font.sans-serif/font.sans-serif/" $setting_path
sed -i "s/# axes.unicode_minus/axes.unicode_minus/" $setting_path
sed -i "s/font.sans-serif     :/font.sans-serif     : Microsoft YaHei, SimHei,/" $setting_path

# flash cache
cd $HOME'/.cache/matplotlib'
rm fontList*