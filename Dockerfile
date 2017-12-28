# MapSplice 2 on ubuntu 14.04
#
# VERSION    0.0.1

# Use ubuntu 14.04 as a parent image
# to use gcc,g++ 4.8
FROM ubuntu:14.04

MAINTAINER Hiroko Tanaka <hiroko@hgc.jp>

ENV MAPSPLICE_VERSION  2.2.1
ENV PYTHON_VERSION 2.7.14

LABEL Description="MapSplice-v$MAPSPLICE_VERSION" \
      Project="Genomon-Project Dockerization" \
      Version="1.0"



# Install required libraries in order to create MapSplice 2
# build-essential package : the set of developement tools (gcc,g++ e.t.c) 
# fatal error: curses.h: No such file or directory => Install libncurses5-dev,libncursesw5-dev

RUN apt-get update && apt-get install -y \
    build-essential \
    libncurses5-dev \
    libncursesw5-dev \
    unzip \
    wget \
    zlib1g-dev \
 && rm -rf /var/lib/apt/lists/*

# create directories for tools
RUN mkdir -p /tools/src /toos/annotation /toos/ref

# Install python
RUN wget https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz \
 && tar xzvf Python-$PYTHON_VERSION.tgz \
 && cd Python-$PYTHON_VERSION \
 && ./configure --prefix=/usr/local \
 && make \
 && make install \
 && cd ../ \
ENV LD_LIBRARY_PATH="/usr/local/lib"

# Install GTF file (809M)
RUN wget http://ftp.ensembl.org/pub/release-75/gtf/homo_sapiens/Homo_sapiens.GRCh37.75.gtf.gz -P /tools/annotation \
 && gunzip /tools/annotation/Homo_sapiens.GRCh37.75.gtf.gz

# Install Bowtie 1 index files & delete FASTA file
RUN wget ftp://ftp.ccb.jhu.edu/pub/data/bowtie_indexes/hg19.ebwt.zip -P /tools/ref \
 && unzip /tools/ref/hg19.ebwt.zip -d /tools/ref/hg19_bowtie 

# Insatall hg19 reference for MapSPlice2
RUN mkdir /tools/ref/hg19_mapsplice && cd /tools/ref/hg19_mapsplice \
 && wget --timestamping ftp://hgdownload.cse.ucsc.edu/goldenPath/hg19/chromosomes/chr?.fa.gz \
 && wget --timestamping ftp://hgdownload.cse.ucsc.edu/goldenPath/hg19/chromosomes/chr??.fa.gz \
 && gunzip *.gz && cd ../../../
 
# install MapSplice 2
RUN wget http://protocols.netlab.uky.edu/~zeng/MapSplice-v$MAPSPLICE_VERSION.zip -P /tools/src \
 && unzip  /tools/src/MapSplice-v$MAPSPLICE_VERSION.zip -d /tools \
 && cd /tools/MapSplice-v$MAPSPLICE_VERSION \
 && make 
WORKDIR /tools/MapSplice-v$MAPSPLICE_VERSION

CMD /usr/bin/g++ --version && python --version

