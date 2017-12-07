FROM nvidia/cuda:8.0-cudnn6-runtime-ubuntu16.04

MAINTAINER Institute of Computer Software, Nanjing University <icsnju@163.com>

ENV APT_INSTALL="apt-get install -y --no-install-recommends"
ENV PIP_INSTALL="pip --no-cache-dir install --upgrade"
ENV GIT_CLONE="git clone --depth 10"

RUN rm -rf /var/lib/apt/lists/* \
     	   /etc/apt/sources.list.d/cuda.list \
           /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get update && \

    # tools
    $APT_INSTALL \
        build-essential \
        curl \
        cmake \
        git \
        wget \
        vim \
        protobuf-compiler \
        pkg-config \
        rsync \
        unzip \
        software-properties-common \

    # Java
        openjdk-8-jdk \
        && \

    # Python
    add-apt-repository ppa:jonathonf/python-3.6 && \
    apt-get update && \
    $APT_INSTALL \
        python3.6 \
        python3.6-dev \
        && \
    ln -s /usr/bin/python3.6 /usr/local/bin/python3 && \
    ln -s /usr/bin/python3.6 /usr/local/bin/python && \

    # Pip
    curl -O https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    rm get-pip.py && \

    $PIP_INSTALL \
        Pillow \
        ipykernel \
        jupyter \
        matplotlib \
        numpy \
        pandas \
        scipy \
        sklearn \
        Cython \
        && \

    # CNTK
   $APT_INSTALL \
       openmpi-bin \
       libpng-dev \
       libtiff-dev \
       libjasper-dev \
       && \
   $PIP_INSTALL \
       https://cntk.ai/PythonWheel/GPU/cntk-2.3-cp36-cp36m-linux_x86_64.whl \
       && \

    # MXNet
    $APT_INSTALL \
        libatlas-base-dev \
        graphviz \
        && \
    $PIP_INSTALL \
        mxnet-cu80 \
        graphviz \
        && \

    # Tensorflow
    $APT_INSTALL \
        libfreetype6-dev \
        libpng12-dev \
        libzmq3-dev \
        && \
    $PIP_INSTALL \
        tensorflow_gpu \
        && \

    # Pytorch
    $PIP_INSTALL \
        http://download.pytorch.org/whl/cu80/torch-0.3.0.post4-cp36-cp36m-linux_x86_64.whl \
        torchvision \
        && \

    # Keras
    $PIP_INSTALL \
        h5py \
        keras \
        && \

    # Caffee
    $APT_INSTALL \
        libboost-all-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libhdf5-serial-dev \
        libleveldb-dev \
        liblmdb-dev \
        libopencv-dev \
        libprotobuf-dev \
        libsnappy-dev \
        && \
    $GIT_CLONE -b 1.0 https://github.com/BVLC/caffe.git /opt/caffe && \
    cd /opt/caffe/python && \
    $PIP_INSTALL -r requirements.txt && \
    $GIT_CLONE https://github.com/NVIDIA/nccl.git /opt/nccl && \
    cd /opt/nccl && \
    make -j"$(nproc)" install && \
    rm -rf /opt/nccl && \
    mkdir /opt/caffe/build && \
    cd /opt/caffe/build && \
    cmake -DUSE_CUDNN=1 -DUSE_NCCL=1 .. && \
    make -j"$(nproc)" && \

    # config and cleanup
    ldconfig && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* ~/*

# Set environment
ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH
ENV PYCAFFE_ROOT /opt/caffe/python
ENV PYTHONPATH $PYCAFFE_ROOT:$PYTHONPATH
ENV PATH $CAFFE_ROOT/build/tools:$PYCAFFE_ROOT:$PATH

RUN echo "$CAFFE_ROOT/build/lib" >> /etc/ld.so.conf.d/caffe.conf && \
    ldconfig

EXPOSE 6006 8888
