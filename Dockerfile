FROM andrewosh/binder-base
MAINTAINER mansourjohn@gmail.com

USER root

# install things
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
        bash-completion \
        build-essential \
        git \
        python \
        python-dev \
        petsc-dev \
        libhdf5-dev \
        python-pip \
        libxml2-dev \
        xorg-dev \
        ssh \
        curl \
        libfreetype6-dev \
        libpng12-dev \
        libxft-dev \
        xvfb \
        freeglut3 \
        freeglut3-dev \
        libgl1-mesa-dri \
        libgl1-mesa-glx \
        rsync \
        vim \
        less \
        xauth \
        swig && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*  && \
    pip install \
        numpy \
        jupyter \
        plotly \
        mpi4py \
        matplotlib \
        runipy


# script for xvfb-run.  all docker commands will effectively run under this via the entrypoint
RUN printf "rm -f /tmp/.X99-lock && xvfb-run -s '-screen 0 1600x1200x16' \$@" >> /usr/local/bin/xvfbrun.sh && \
    chmod +x /usr/local/bin/xvfbrun.sh

# set working directory to /root
WORKDIR /root

# setup environment
ENV PYTHONPATH $PYTHONPATH:/root/underworld2

# get underworld, compile, delete some unnecessary files, run tests.
RUN git clone https://github.com/underworldcode/underworld2 && \
    cd underworld2/libUnderworld && \
    ./configure.py --hdf5-dir=/usr/lib/x86_64-linux-gnu/hdf5/serial/            && \
    ./scons.py                   && \
    cd libUnderworldPy           && \
    ./swigall.py                 && \
    cd ..                        && \
    ./scons.py                   && \
    rm .sconsign.dblite          && \
    rm -fr .sconf_temp           && \
    cd build                     && \
    rm -fr libUnderworldPy       && \
    rm -fr StGermain             && \
    rm -fr gLucifer              && \
    rm -fr Underworld            && \
    rm -fr StgFEM                && \
    rm -fr StgDomain             && \
    rm -fr PICellerator          && \
    rm -fr Solvers

# note we also use xvfb which is required for viz
ENTRYPOINT ["xvfbrun.sh"]

USER main



