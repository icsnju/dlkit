FROM nvidia/cuda:8.0-cudnn6-devel-ubuntu16.04

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

    # Boost
    wget -O ~/boost.tar.gz https://dl.bintray.com/boostorg/release/1.65.1/source/boost_1_65_1.tar.gz && \
    tar -zxf ~/boost.tar.gz -C ~ && \
    cd ~/boost_* && \
    ./bootstrap.sh --with-python=python3.6 && \
    ./b2 install --prefix=/usr/local && \

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
    
    # OpenCV
    $APT_INSTALL \
        libatlas-base-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libhdf5-serial-dev \
        libleveldb-dev \
        liblmdb-dev \
        libprotobuf-dev \
        libsnappy-dev \
        protobuf-compiler \
        && \

    $GIT_CLONE https://github.com/opencv/opencv ~/opencv && \
    mkdir -p ~/opencv/build && cd ~/opencv/build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D WITH_IPP=OFF \
          -D WITH_CUDA=OFF \
          -D WITH_OPENCL=OFF \
          -D BUILD_TESTS=OFF \
          -D BUILD_PERF_TESTS=OFF \
          .. && \
    make -j"$(nproc)" install && \

    # Caffee
#    $GIT_CLONE https://github.com/NVIDIA/nccl ~/nccl && \
#    cd ~/nccl && \
#    make -j"$(nproc)" install && \

#    $GIT_CLONE https://github.com/BVLC/caffe ~/caffe && \
#    cp ~/caffe/Makefile.config.example ~/caffe/Makefile.config && \
#    sed -i 's/# USE_CUDNN/USE_CUDNN/g' ~/caffe/Makefile.config && \
#    sed -i 's/# PYTHON_LIBRARIES/PYTHON_LIBRARIES/g' ~/caffe/Makefile.config && \
#    sed -i 's/# WITH_PYTHON_LAYER/WITH_PYTHON_LAYER/g' ~/caffe/Makefile.config && \
#    sed -i 's/# OPENCV_VERSION/OPENCV_VERSION/g' ~/caffe/Makefile.config && \
#    sed -i 's/# USE_NCCL/USE_NCCL/g' ~/caffe/Makefile.config && \
#    sed -i 's/2\.7/3\.6/g' ~/caffe/Makefile.config && \
#    sed -i 's/3\.5/3\.6/g' ~/caffe/Makefile.config && \
#    sed -i 's/\/usr\/lib\/python/\/usr\/local\/lib\/python/g' ~/caffe/Makefile.config && \
#    sed -i 's/\/usr\/local\/include/\/usr\/local\/include \/usr\/include\/hdf5\/serial/g' ~/caffe/Makefile.config && \
#    sed -i 's/hdf5/hdf5_serial/g' ~/caffe/Makefile && \
#    cd ~/caffe && \
#    make -j"$(nproc)" -Wno-deprecated-gpu-targets distribute && \

    # fix ValueError caused by python-dateutil 1.x
#    sed -i 's/,<2//g' ~/caffe/python/requirements.txt && \

#    $PIP_INSTALL \
#       -r ~/caffe/python/requirements.txt && \

#    cd ~/caffe/distribute/bin && \
#    for file in *.bin; do mv "$file" "${file%%.bin}"; done && \
#    cd ~/caffe/distribute && \
#    cp -r bin include lib proto /usr/local/ && \
#    cp -r python/caffe /usr/local/lib/python3.6/dist-packages/ && \

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
