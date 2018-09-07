# modified from https://github.com/jaimeps/docker-rl-gym
FROM ubuntu:16.04
#FROM nvidia/cuda:9.2-cudnn5-devel-ubuntu16.04


WORKDIR /home
RUN mkdir src

ENV DEBIAN_FRONTEND noninteractive

# Ubuntu packages + Numpy
RUN apt-get update \
     && apt-get install -y --no-install-recommends \
        apt-utils \
        build-essential \
        sudo \
        less \
        vim \
        jed \
        g++  \
        git  \
        curl  \
        cmake \
        zlib1g-dev \
        libjpeg-dev \
        xvfb \
        libav-tools \
        xorg-dev \
        libboost-all-dev \
        libsdl2-dev \
        dbus \
        swig \
        python3  \
        python3-dev  \
        python3-future  \
        python3-pip  \
        python3-setuptools  \
        python3-wheel  \
        python3-tk \
        python3-opengl \
        libopenblas-base  \
        libatlas-dev  \
        lxterminal \
#        cython3  \
     && apt-get upgrade -y \
     && apt-get clean \
     && rm -rf /var/lib/apt/lists/*

# use python3.5 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.5 1
RUN sudo update-alternatives --config python

# upgrade pip
RUN python3 -m pip install --upgrade pip


# Step 1: basic python packages
COPY requirements_1.txt /tmp/
RUN python3 -m pip install -r /tmp/requirements_1.txt

# Step 2: install Deep Learning packages
# at first delete numpy that doesn't match to tensorflow 1.10.0
#RUN python3 -m pip uninstall numpy
COPY requirements_2.txt /tmp/
RUN python3 -m pip install -r /tmp/requirements_2.txt

# Step 3: install OpenAI Gym and PyGame (PLE)
COPY requirements_3.txt /tmp/
RUN python3 -m pip install -r /tmp/requirements_3.txt

# Step 4: install gridworld
ENV GYMDIR /usr/local/lib/python3.5/dist-packages/gym/envs/
COPY gridworld-gym/env_register.txt /tmp/
RUN cat /tmp/env_register.txt >> ${GYMDIR}/__init__.py
COPY gridworld-gym/envs/mdp_gridworld.py ${GYMDIR}/toy_text/
RUN  echo "from gym.envs.toy_text.mdp_gridworld import MDPGridworldEnv" >> ${GYMDIR}/toy_text/__init__.py

# Step 5: install Roboschool

RUN apt-get update && apt-get install -y \
      pkg-config \
      qtbase5-dev \
      libqt5opengl5-dev \
      libassimp-dev \
      libpython3.5-dev \
      libboost-python-dev \
      libtinyxml-dev \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

WORKDIR /opt

RUN git clone --depth 1 https://github.com/olegklimov/bullet3 -b roboschool_self_collision \
    && git clone --depth 1 https://github.com/openai/roboschool

# export ROBOSCHOOL_PATH=/opt/roboschool
ENV ROBOSCHOOL_PATH /opt/roboschool

RUN mkdir -p /opt/bullet3/build \
    && cd /opt/bullet3/build \
    && cmake -DBUILD_SHARED_LIBS=ON -DUSE_DOUBLE_PRECISION=1 \
       -DCMAKE_INSTALL_PREFIX:PATH=${ROBOSCHOOL_PATH}/roboschool/cpp-household/bullet_local_install \
       -DBUILD_CPU_DEMOS=OFF -DBUILD_BULLET2_DEMOS=OFF \
       -DBUILD_EXTRAS=OFF  -DBUILD_UNIT_TESTS=OFF \
       -DBUILD_CLSOCKET=OFF -DBUILD_ENET=OFF \
       -DBUILD_OPENGL3_DEMOS=OFF .. \
    && make -j4 \
    && make install \
    && pip3 install -e ${ROBOSCHOOL_PATH} \
    && ldconfig \
    && make clean

# Step 6: install graphic driver
RUN apt-get install -y libgl1-mesa-dri libgl1-mesa-glx --no-install-recommends
RUN dbus-uuidgen > /etc/machine-id

# Step 7: install locate
RUN apt-get update && apt-get install -y mlocate \
    && updatedb \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*


# create user account
ENV USER jovyan
ENV HOME /home/${USER}
RUN export uid=1000 gid=1000 &&\
    echo "${USER}:x:${uid}:${gid}:Developer,,,:${HOME}:/bin/bash" >> /etc/passwd &&\
    echo "${USER}:x:${uid}:" >> /etc/group &&\
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers &&\
    install -d -m 0755 -o ${uid} -g ${gid} ${HOME}
WORKDIR ${HOME}

# Install some scripts
COPY jupyter.sh /usr/bin
COPY aliases.sh /etc/profile.d

# Enable jupyter extensions
RUN jupyter nbextensions_configurator enable --system
RUN jupyter nbextension enable --py --sys-prefix widgetsnbextension

ENV DEBIAN_FRONTEND teletype

# X
ENV DISPLAY :0.0
VOLUME /tmp/.X11-unix
VOLUME ${HOME}
USER ${USER}

#CMD [ "/bin/bash" ]

# Jupyter notebook with virtual frame buffer
CMD cd ${HOME} \
    && xvfb-run -s "-screen 0 1024x768x24" \
    /usr/local/bin/jupyter notebook \
    --port=8888 --ip=0.0.0.0 --allow-root 



