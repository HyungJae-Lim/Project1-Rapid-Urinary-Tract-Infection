#######################################################################
# Author: Nikolaus Mayer (2018), mayern@cs.uni-freiburg.de
#######################################################################
#FROM nvcr.io/nvidia/l4t-tensorflow:r32.4.2-tf1.15-py3
FROM nvcr.io/nvidia/l4t-base:r32.4.2

## Container's mount points for the host's input/output folders
VOLUME "/input"
VOLUME "/output"

RUN apt update                             && \
    apt install -y --no-install-recommends    \
    apt-utils                                 \
    python3                                   \
    python3-distutils                         \
    cmake                                     \
    git                                       \
    curl                                      \
    wget                                      \
    libeigen3-dev                             \
    sudo
RUN apt-get update && apt-get install -y build-essential libatlas-base-dev
RUN apt-get update && apt-get install -y --fix-missing make g++
RUN apt-get update && apt-get install -y --fix-missing python3-pip libhdf5-serial-dev hdf5-tools libhdf5-dev zlib1g-dev zip libjpeg8-dev liblapack-dev libblas-dev gfortran
RUN apt-get update && apt-get install -y python3-h5py
#RUN pip3 install -U numpy==1.16.1
#RUN pip3 install --pre --no-cache-dir --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v44 'tensorflow<2'

## Switch to non-root user 
ARG uid
ARG gid
ENV uid=${uid}
ENV gid=${gid}
ENV USER=netdef
RUN groupadd -g $gid $USER                                              && \
    mkdir -p /home/$USER                                                && \
    echo "${USER}:x:${uid}:${gid}:${USER},,,:/home/${USER}:/bin/bash"      \
         >> /etc/passwd                                                 && \
    echo "${USER}:x:${uid}:"                                               \
         >> /etc/group                                                  && \
    echo "${USER} ALL=(ALL) NOPASSWD: ALL"                                 \
         > /etc/sudoers.d/${USER}                                       && \
    chmod 0440 /etc/sudoers.d/${USER}                                   && \
    chown ${uid}:${gid} -R /home/${USER}

USER ${USER}
ENV HOME=/home/${USER}

WORKDIR ${HOME}
COPY requirements.txt .
RUN sudo curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py   && \
    sudo python3 get-pip.py                                        && \
#    wget --no-check-certificate https://lmb.informatik.uni-freiburg.de/resources/binaries/tensorflow-binaries/tensorflow-1.11.0-cp36-cp36m-linux_aarch64.whl && \
    sudo -H pip3 install -r requirements.txt                       && \
#    sudo -H pip3 install ${HOME}/tensorflow-1.11.0-cp36-cp36m-linux_aarch64.whl && \
#    sudo -H pip3 install tensorflow-1.15.0-cp36-cp36m-linux_aarc64.whl       && \
    sudo -H pip3 install --pre --no-cache-dir --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v44/tensorflow-1.15.2+nv20.4-cp36-cp36m-linux_aarch64.whl      && \
#    sudo -H pip3 install scikit-learn pillow scipy
COPY lmbspecialops ${HOME}/lmbspecialops
RUN sudo chown -R ${USER}.${USER} ${HOME}/lmbspecialops
#git clone https://github.com/lmb-freiburg/lmbspecialops && \
RUN cd ${HOME}/lmbspecialops                                        && \
#    git checkout -b 3e01ebaf0da6a5d0545f1ffead4bccdbe79a26f5   && \
    find . -type f -print0 | xargs -0 sed -i 's/data.starts_with(/str_util::StartsWith(data,/g' && \
    find . -type f -print0 | xargs -0 sed -i 's/^set_target_properties.*GLIBCXX_USE_CXX11_ABI.*/#/g' && \
    mkdir build                                             && \
    cd build                                                && \
    sudo ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1 && \
    export LD_LIBRARY_PATH=/usr/local/cuda/lib64/stubs/:$LD_LIBRARY_PATH && \
    cmake ..                                                && \
    make -j                                                 && \
    sudo rm /usr/local/cuda/lib64/stubs/libcuda.so.1

RUN git clone https://github.com/lmb-freiburg/netdef_slim   && \
    cd netdef_slim                                          && \
    git checkout 54f101d0f6a0bb1b815b808754176e2732e8de77   && \
    cd ..                                                   && \
    git clone https://github.com/lmb-freiburg/netdef_models && \
    cd netdef_models                                        && \
    git checkout 7d3311579cf712b31d05ec29f3dc63df067aa07b   && \
    cd DispNet3  && bash download_snapshots.sh && cd ..     && \
    cd FlowNet3  && bash download_snapshots.sh && cd ..     && \
    cd FlowNetH  && bash download_snapshots.sh && cd ..
    #cd SceneFlow && bash download_snapshots.sh && cd ..

