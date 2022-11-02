FROM ubuntu:18.04 as cacher

# Avoid libopencv-dev tzdata interaction
ARG DEBIAN_FRONTEND=noninteractive 

# Set working directory
RUN mkdir /vsss_ws
WORKDIR /vsss_ws

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    g++ \
    cmake \
    git \
    qt5-default \
    libqt5opengl5-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libprotobuf-dev \
    protobuf-compiler \
    v4l-utils \
    libode-dev \
    libboost-dev \
    sudo && \
    apt-get clean && \
    cd /tmp && \
    git clone https://github.com/jpfeltracco/vartypes.git &&\
    cd vartypes && \
    mkdir build && cd build && \
    cmake .. && make && sudo make install

# Dependencies for glvnd and X11.
RUN apt-get update \&& apt-get install -y -qq --no-install-recommends \
    libglvnd0 \
    libgl1 \
    libglx0 \
    libegl1 \
    libxext6 \
    libx11-6 \
    && rm -rf /var/lib/apt/lists/*

FROM cacher as builder

# Install VSSReferee
# RUN cd /vsss_ws && \
#     git clone https://github.com/VSSSLeague/VSSReferee.git && \
#     cd VSSReferee && \
#     git checkout CBFRS

# RUN cd /vsss_ws/VSSReferee && \
#     mkdir build && cd build && qmake .. && make

# Install SSL-VISION
RUN apt-get update && \
    cd /vsss_ws && \
    git clone https://github.com/fbot-furg/ssl-vision.git && \
    cd ssl-vision && \
    sh InstallPackagesUbuntu.sh && \
    mkdir build && \
    cd build && \
    cmake -DUSE_V4L=true .. && \
    cd .. && \
    make

FROM builder as runner

# Set enviroment variables
ENV DISPLAY=:0
ENV QT_X11_NO_MITSHM=1

ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES graphics,utility,compute

RUN mkdir -m 700 /tmp/runtime-root
ENV XDG_RUNTIME_DIR=/tmp/runtime-root

COPY constants.json /vsss_ws/VSSReferee/src/constants/

# Run ssl-vision and VSSReferee
# CMD /vsss_ws/VSSReferee/bin/VSSReferee --3v3 --record false
# CMD cd /vsss_ws/ssl-vision && ./bin/vision -c 1;

