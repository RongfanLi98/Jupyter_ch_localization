FROM jupyter/datascience-notebook:be289da10d60

LABEL maintainer="Lirongfan <lirongfan@orientsoft.cn>"

# CMD ["start-notebook.sh"] from https://hub.docker.com/r/jupyter/base-notebook/dockerfile

USER root

COPY ./files/ ./

RUN apt-get update\
    # chinese localization
    && apt-get install -y fontconfig \
    ttf-mscorefonts-installer\
    texlive-xetex\
    latex-cjk-chinese\
    texlive-fonts-recommended\
    language-pack-zh-hans language-pack-zh-hans-base\
    && apt-get -y autoremove && apt-get -y autoclean\
    && rm -rf /var/lib/apt/lists/* \
    # TOC extension and babel
    && conda install -c conda-forge jupyter_contrib_nbextensions babel\ 
    # extensions
    autopep8

ENV LC_ALL=zh_CN.UTF-8 LANG=zh_CN.UTF-8 LANGUAGE=zh_CN:zh:en_US:en
# $HOME is '/home/jovyan'
RUN bash -c '/bin/echo -e "y\n" | bash ./temporary/config.sh'

ENTRYPOINT ["bash"]
CMD ["/usr/local/bin/my_start.sh"]

# /usr/local/bin/start-notebook.sh