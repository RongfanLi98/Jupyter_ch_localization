# Chinese_localization
## 目的

jupyter notebook的使用中，有这样三个问题

1. 中文界面并不稳定，有些人可以看到中文界面，有些看不到
2. 无法正常下载有中文的PDF
3. matplotlib和基于它的包画出的图没有中文

这三个问题困扰着中文使用者。这个项目就是针对这些问题，对jupyter做的一些修复改造工作。  

同时，为了使得notebook的使用更加方便，里面添加了jupyter_contrib_nbextensions，也就是插件系统，并启用了目录插件。

## 文件结构

1. ch_doc  
    1. jupyter_ch.md 是解决matplotlib使用中，jupyter无法输出中文pdf和图像的方案,jupyter_ch.sh是脚本参考, jupyter_en.md是英文教程  
    2. matplot_ch.md是在matplotlib中绘图无法显示中文的解决方案，matplot_ch.sh是脚本参考
3. ch_localization  
有构建docker镜像的配置文件和对应的功能性测试文件

## 操作指南

1. 所有的代码仅经过我个人的测试，如果有没有考虑到的特殊情况，请酌情自己修改代码
2. 启动和关闭  
    首先将ch_localization下的全部文件copy到想要的地方。
    * 在dockerfile同级文件夹下执行以下命令即可  
        ```
        docker build --rm -f "ch_localization/Dockerfile" -t ch_localization:$tag ch_localization
        ```
        注意这里的`ch_localization:$tag`是需要你自己去定义的。
    * 在docker-compose.yml同级文件夹下，有.env文件指定了yaml文件的环境变量。修改环境变量并执行以下命令便可以创建新的容器。
        ```
        docker-compose up
        ```
    * 如果想进入其控制终端，用`docker container ls`来查询containerID，然后执行
        ```
        docker exec -it ${containerID} /bin/sh -c "[ -e /bin/bash ] && /bin/bash || /bin/sh"
        ```
    * 关闭则只需查找到container id然后执行`docker container stop ${container_id}`即可。注意docker-compose会出现查询不到container的情况，需要在yml文件的同级目录下查询，或者直接在这个目录下执行`docker-compose down`

3. 具体操作  
    * 如果你需要jupyter的中文化，请参考ch_doc/jupyter_ch.sh
    * 如果你需要matplotlib打印出中文，请参考ch_doc/matplot_ch.sh
    * ch_localization/files/config.sh是上面两个功能的整合，并且有更丰富的功能。

4. 权限问题
    * 如果要映射宿主机的文件夹: 由于映射的文件夹的权限原因，会导致无法创建新的文件，请修改宿主机的文件夹的权限，比如`chmod 777 ${dir_path} -R`或者是搜索其他解决办法。
    * 初始存在的文件，如测试文件等，都是只读文件，创建者是root，在jupyter页面是无法修改的。如果想删除请尝试下面的方法。
        * 容器启动后，进入其控制终端，用`docker container ls`来查询containerID，然后执行`docker exec -it ${containerID} /bin/sh -c "[ -e /bin/bash ] && /bin/bash || /bin/sh"`，进入容器后到指定的位置删除文件即可。
        * 修改`ch_localization\files\test_files`下的文件，这个文件夹下的全部内容都将被copy到jupyter的根目录。调整完后重新build新的image。
    

## 操作简介

下面将简单介绍主要配置文件做了什么工作。  
dockerfile  
1. 复制files下的全部文件到./ 
2. apt安装中文内容需要的依赖，删除缓存
3. conda安装nbextension，启用目录插件
4. 安装notebooks需要的依赖
5. 执行config.sh

config.sh  
1. 查看python和conda的版本是否符合预期
2. 移动文件到指定的位置，从python中获取各种路径
3. 添加i18n的信息，修改dockerfile指定的CMD启动脚本
4. 添加字体，在Linux系统中添加字体索引信息
5. 配置matplotlib和latex
6. 配置jupyter
7. 重新载入matplotlib的配置信息
8. 删除不需要的文件

docker-compose.yml和env
1. docker-compose.yml指定了采用的镜像名称，规定了映射的文件夹和端口号，容器命名，以及修改了启动命令
2. env文件规定了环境变量

## 仍然存在的问题
1. 插件系统的安装导致了中文的不全面

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
    所以目前的js的中文化全部是在json文件上直接更改的。如果想要编译这个文件，请在config.sh中找到
    ```
    # po2json -p -F -f jed1.x -d nbjs zh_CN/LC_MESSAGES/nbjs.po zh_CN/LC_MESSAGES/nbjs.json
    ```
    这个命令是官方建议的命令。  
    目前想到的还没实施的解决方案是，用其他途径来编译这个文件。