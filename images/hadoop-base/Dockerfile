FROM ubuntu:14.04
MAINTAINER Bo ZHANG <bo.zhang@inria.fr>

# prerequisite
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update -yqq && \
    apt-get install -yqq \
		  curl \
	    vim \
	    openjdk-7-jdk

# download and install Hadoop
RUN curl http://www.eu.apache.org/dist/hadoop/common/hadoop-2.7.1/hadoop-2.7.1.tar.gz | tar -xz -C /usr/local/ && \
    ln -s /usr/local/hadoop-2.7.1 /usr/local/hadoop
