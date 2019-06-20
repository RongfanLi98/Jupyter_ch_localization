# 问题描述
Jupyterhub调用镜像启动容器的时候，无法正常启动TOC(table of ocntent)插件。

# 问题来源
1. 如果要启动TOC插件，则在配置文件`$HOME/.jupyter/nbconfig/notebook.json`中，修改`"toc2/main": true`即可。这个文件一般而言如下所示  
    ```json
    {  
        "load_extensions": 
        {    
            "toc2/main": true  
        }
    }​
    ```
    有两种方式可以达到修改的目的。一是在终端中执行
    ```shell
    jupyter nbextension enable toc2/main
    ```
    或者执行
    ```shell
    sed -i 's/false/true/g' $HOME/.jupyter/nbconfig/notebook.json
    ```
    选择的关键在于路径下是否有这个文件。没有则用命令启动，如果有则都可以。  
    使用`jupyter --paths`可以查看全部配置文件夹。  
2. 原本的镜像中，在dockerfile中使用了`jupyter nbextension enable toc2/main`来启动TOC。而dockerfile是采用的默认容器启动命令，见jupyter base-notebook镜像[官方dockerfile](https://github.com/jupyter/docker-stacks/blob/master/base-notebook/Dockerfile)
    ```dockerfile
    ENTRYPOINT ["tini", "-g", "--"]
    CMD ["start-notebook.sh"]
    ```
    关于tini的原理不在此赘述。
3. 在jupyterhub的配置文件，`/root/workshop/helm/jupyterhub/config-moop-dev.yaml`中，有一句cmd命令，在官方镜像之后运行，即会覆盖掉官方命令的内容，所以启动命令变成了`tini -g -- jupyterhub-singleuser --ip="0.0.0.0" --port=8888 --debug`，后面的参数也来自于jupyterhub的配置。  
4. 在被jupyterhub调用的镜像，会被修改，导致之前的配置无效。本问题面临的，就是$HOME文件夹下几乎全部内容都被修改，导致配置文件被重新写成了`"toc2/main": false`。  
与此同时，其他文件夹不受影响，故而其他的中文配置完全正常。

# 解决方案
方案就是，修改jupyterhub的cmd和这个项目下的cmd，让容器以我们想要的方式来启动，在基础镜像被修改的前提下，再次进行配置，最终使TOC能正常启动。
1. 在基础镜像的dockerfile中，修改如下  
    ```dockerfile
    ENTRYPOINT ["bash"]
    CMD ["/usr/local/bin/my_start.sh"]
    ```
    而my_start.sh的内容如下
    ```shell
    #!/bin/bash
    jupyter nbextension enable toc2/main
    bash /usr/local/bin/start-notebook.sh
    ```
    即在原本的启动命令基础上，增加了启动TOC的命令。由于启动命令后可能有参数，所以在这里用了一个shell脚本替代，将多个命令整理进去。
2. 修改`config-moop-dev.yaml`的cmd如下
    ```yaml
    cmd: /usr/local/bin/my_start.sh
    ```
    千万注意不要放在`$HOME`目录下。这里参考了jupyter项目的做法，将启动脚本放在了`/usr/local/bin`，只需要在dockerfile中将文件移动到目标位置，保证两者相同即可。