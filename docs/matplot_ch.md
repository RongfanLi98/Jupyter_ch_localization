### 问题描述

​	使用matplot和seaborn之类的基于matplot的package绘图的时候，无法正常显示中文字符。

### 原因

1. matplotlib只支持ascll，而不支持unicode，所以无法正常显示中文,需要字体库的支持。
2. matplotlib只支持ttf格式的字体，而不支持ttc格式，ttc相当于是多个ttf叠加而成的新格式。
3. 调用```matplotlib.font_manager.ttflist```可以返回元素类型FontEntry的一个list，打印后可以看出，内部的库全都是ttf格式，调用```matplotlib.fontManager.defaultFont```可以查看字体库位置，我的实验下，路径是```/home/lenke/anaconda3/lib/python3.7/site-packages/matplotlib/mpl-data/fonts/ttf/cmex10.ttf```。可以发现目录里全部都是ttf格式字体。
4. 在```~/.cache/matplotlib```目录下可以看见matplotlib的字体配置json文件缓存，里面记载了全部matplotlib可用字体。
5. Linux里的字体成分复杂，但是中文字体几乎都是ttc格式，见```fc-list :lang=zh-cn```。```fc-list :lang=zh | grep 'ttf'```发现只有一个字体，Droid Sans Fallback，但是在python里面用```plt.rcParams['font.sans-serif'] = ['Droid Sans Fallback']```配置后，中文英文都不能正常显示了。
6. Windows下有丰富的ttf格式字体，在```C:/Windows/Fonts```目录下，可以看见有很多ttf，比如msyh.ttf是著名的微软雅黑。

### 方案

总体方案就是，复制字体到matplotlib字体库中，和Linux字体库中，安装好后更改matplotlib配置文件，刷新缓存，就可以了。下面是具体的步骤。

1. 找到合适的字体

   可以在Windows下面复制字体，也可以到网络上下载合适的字体。github上有别人搜集的免费字体，[字体下载](https://github.com/tracyone/program_font)。我选择的是微软雅黑msyh和中易黑体simhei。

2. 复制到Linux字体库

   将字体复制到```/usr/share/fonts/```下的任意目录，最好自己创建一个，比如```/usr/share/fonts/ch```。然后在目录下执行以下代码。

   ```shell
   # 创建索引信息
   sudo mkfontscale
   sudo mkfontdir
   # 更新字体缓存
   fc-cache
   ```

   再次使用```fc-list :lang=zh|grep ttf```就可以看见新的可用中文ttf字体了。

3. 复制字体到matplotlib字体库，此步不一定要做

   将字体文件复制到```/home/lenke/anaconda3/lib/python3.7/site-packages/matplotlib/mpl-data/fonts/ttf/```。

4. 更改matplotlib配置文件

   * 多种方法都可以找到配置文件路径。可以在python中执行```print(matplotlib.matplotlib_fname())```，也可以直接根据matplotlib字体库路径，找到```/home/lenke/anaconda3/lib/python3.7/site-packages/matplotlib/mpl-data/```，下面有matplotlibrc文件，就是配置文件。
   * 找到```font-family:sans-serif```，取消此行注释。如果font-family后是其他内容，下面的配置跟着一起更改便是。
   * 找到下面不远处的```font.sans-serif```，取消此行注释，并在后面的字体名称列表中增加字体名称。比如Microsoft YaHei，SimHei。
   * 关于如何获取字体名称：```fc-list :lang=zh|grep ttf```，注意字体文件名称和字体的规范名称是不一样的，比如微软雅黑的字体文件叫msyh.ttf，而正式的字体名称叫Microsoft YaHei。
   * 如果出现了中文减号也无法正常显示的问题，找到```axes.unicode_minus  : False ```取消注释即可。

5. 刷新matplotlib缓存

   删除~/.cache/matplotlib下的字体缓存，再次运行绘图程序即可，第一次运行可能会出问题，第二次等缓存好了再运行便不会有问题。
 
6. reload  
    如果仍然不行，就重新载入
    ```
    from matplotlib.font_manager import _rebuild
    _rebuild()
    ```

### 参考

<https://matplotlib.org/gallery/api/font_family_rc_sgskip.html>

<https://www.jianshu.com/p/7b7a3e73ef21>

<https://www.cnblogs.com/arkenstone/p/6411055.html>