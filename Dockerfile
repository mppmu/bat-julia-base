FROM centos:7


# User and workdir settings:

USER root
WORKDIR /root


# Install yum/RPM packages:

COPY provisioning/wandisco-centos7-git.repo /etc/yum.repos.d/wandisco-git.repo

RUN true \
    && sed -i '/tsflags=nodocs/d' /etc/yum.conf \
    && yum install -y \
        epel-release \
    && yum groupinstall -y "Development Tools" \
    && yum install -y \
        deltarpm \
        \
        wget \
        cmake \
        p7zip pbzip2 \
        nano vim \
        git git-gui gitk \
    && dbus-uuidgen > /etc/machine-id


# Copy provisioning script(s):

COPY provisioning/install-sw.sh /root/provisioning/


# Install CMake:

COPY provisioning/install-sw-scripts/cmake-* provisioning/install-sw-scripts/

ENV \
    PATH="/opt/cmake/bin:$PATH" \
    MANPATH="/opt/cmake/share/man:$MANPATH"

RUN provisioning/install-sw.sh cmake 3.5.1 /opt/cmake


# Install CERN ROOT:

COPY provisioning/install-sw-scripts/root-* provisioning/install-sw-scripts/

ENV \
    PATH="/opt/root/bin:$PATH" \
    LD_LIBRARY_PATH="/opt/root/lib:$LD_LIBRARY_PATH" \
    MANPATH="/opt/root/man:$MANPATH" \
    PYTHONPATH="/opt/root/lib:$PYTHONPATH" \
    CMAKE_PREFIX_PATH="/opt/root;$CMAKE_PREFIX_PATH" \
    JUPYTER_PATH="/opt/root/etc/notebook:$JUPYTER_PATH" \
    \
    ROOTSYS="/opt/root"

RUN true \
    && yum install -y \
        libSM-devel \
        libX11-devel libXext-devel libXft-devel libXpm-devel \
        libjpeg-devel libpng-devel \
        mesa-libGLU-devel \
    && provisioning/install-sw.sh root 6.08.06 /opt/root


# Install Anaconda2:

COPY provisioning/install-sw-scripts/anaconda2-* provisioning/install-sw-scripts/

ENV \
    PATH="/opt/anaconda2/bin:$PATH" \
    MANPATH="/opt/anaconda2/share/man:$MANPATH" \
    JUPYTER=jupyter

    # JUPYTER environment variable used by IJulia to detect Jupyter installation

RUN true \
    && yum install -y \
        libXdmcp \
        texlive-collection-latexrecommended texlive-adjustbox texlive-upquote texlive-ulem \
    && provisioning/install-sw.sh anaconda2 4.4.0 /opt/anaconda2 \
    && conda install -c conda-forge nbpresent pandoc \
    && conda install -c anaconda-nb-extensions nbbrowserpdf \
    && conda install -c damianavila82 rise \
    && pip install jupyterlab metakernel bash_kernel \
    && JUPYTER_DATA_DIR="/opt/anaconda2/share/jupyter" python -m bash_kernel.install

EXPOSE 8888


# Install Julia:

COPY provisioning/install-sw-scripts/julia-* provisioning/install-sw-scripts/

ENV \
    PATH="/opt/julia/bin:$PATH" \
    LD_LIBRARY_PATH="/opt/julia/lib:$LD_LIBRARY_PATH" \
    MANPATH="/opt/julia/share/man:$MANPATH" \
    JULIA_HOME="/opt/julia/bin" \
    JULIA_CXX_RTTI="1"

RUN true \
    && yum install -y \
        libedit-devel ncurses-devel openssl openssl-devel \
        ImageMagick zeromq-devel gtk2 gtk3 \
    && provisioning/install-sw.sh julia 0.5.1 /opt/julia \
    && provisioning/install-sw.sh julia-cxx oschulz/julia0.5-root /opt/julia/share/julia/site


# Install BAT:

COPY provisioning/install-sw-scripts/bat-* provisioning/install-sw-scripts/

ENV \
    PATH="/opt/bat/bin:$PATH" \
    LD_LIBRARY_PATH="/opt/bat/lib:$LD_LIBRARY_PATH" \
    CPATH="/opt/bat/include:$CPATH" \
    PKG_CONFIG_PATH="/opt/bat/lib/pkgconfig:"

RUN true \
    && provisioning/install-sw.sh bat bat/master /opt/bat


# Install HDF5:

COPY provisioning/install-sw-scripts/hdf5-* provisioning/install-sw-scripts/

ENV \
    PATH="/opt/hdf5/bin:$PATH" \
    LD_LIBRARY_PATH="/opt/hdf5/lib:$LD_LIBRARY_PATH"

RUN provisioning/install-sw.sh hdf5 1.10.0-patch1 /opt/hdf5


# Install HDFView:

COPY provisioning/install-sw-scripts/hdfview-* provisioning/install-sw-scripts/

ENV PATH="/opt/hdfview/bin:$PATH"

RUN provisioning/install-sw.sh hdfview 2.13.0 /opt/hdfview


# Install GitHub Atom:

RUN yum install -y \
        lsb-core-noarch libXScrnSaver libXss.so.1 gtk3 libXtst libxkbfile GConf2 alsa-lib \
        levien-inconsolata-fonts dejavu-sans-fonts \
    && rpm -ihv https://github.com/atom/atom/releases/download/v1.17.2/atom.x86_64.rpm


# Install additional packages and clean up:

RUN yum install -y \
        numactl \
        readline-devel fftw-devel \
        graphviz-devel \
        \
        http://linuxsoft.cern.ch/cern/centos/7/cern/x86_64/Packages/parallel-20150522-1.el7.cern.noarch.rpm \
    && yum clean all


# Set container-specific SWMOD_HOSTSPEC:

ENV SWMOD_HOSTSPEC="linux-centos-7-x86_64-05f7b329"


# Final steps

CMD /bin/bash
