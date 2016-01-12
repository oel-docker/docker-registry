# VERSION 0.1
# DOCKER-VERSION  0.7.3
# AUTHOR:         Tim Langford <tim,langford@gmail.com>
# DESCRIPTION:    Image with docker-registry project and dependecies
# TO_BUILD:       docker build -rm -t registry .
# TO_RUN:         docker run -p 5000:5000 registry

FROM oraclelinux:7.2

# Update
# RUN apt-get update \
# Install pip
#    && apt-get install -y \
#        swig \
#        python-pip \
# Install deps for backports.lzma (python2 requires it)
#        python-dev \
#        python-mysqldb \
#        python-rsa \
#        libssl-dev \
#        liblzma-dev \
#        libevent1-dev \
#    && rm -rf /var/lib/apt/lists/*

RUN yum -y update

# Install 'pip'
#
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN python get-pip.py

RUN yum -y install swig python-devel
# RUN yum -y install openssl-devel.x86_64 xz-devel
RUN yum -y install xz-devel
RUN yum -y install patch
RUN yum -y install tar git gcc make

# RUN env SWIG_FEATURES="-cpperraswarn -includeall -I/usr/include/openssl"
# RUN pip install M2Crypto

# RUN curl -O http://tukaani.org/xz/xz-5.0.4.tar.gz
# RUN tar -zxvf xz-5.0.4.tar.gz
# WORKDIR /xz-5.0.4
# RUN ./configure --prefix=$HOME
# RUN make
# RUN make check
# RUN make install
# WORKDIR /


RUN git clone git://github.com/peterjc/backports.lzma.git
WORKDIR /backports.lzma
RUN python setup.py install
# TODO: Fix tests...
# WORKDIR /backports.lzma/test
# RUN python test_lzma.py
WORKDIR /

COPY . /docker-registry
COPY ./config/boto.cfg /etc/boto.cfg

# Install core
RUN pip install /docker-registry/depends/docker-registry-core

# Install registry
#
# RUN pip install file:///docker-registry#egg=docker-registry[bugsnag,newrelic,cors]

# RUN patch \
#     $(python -c 'import boto; import os; print os.path.dirname(boto.__file__)')/connection.py \
#     < /docker-registry/contrib/boto_header_patch.diff

ENV DOCKER_REGISTRY_CONFIG /docker-registry/config/config_sample.yml
ENV SETTINGS_FLAVOR dev

EXPOSE 5000

CMD ["docker-registry"]
