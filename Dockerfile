FROM ubuntu:15.04

MAINTAINER Bo ZHANG <bo.zhang@inria.fr>

#prerequisite
RUN apt-get update && \
	apt-get install -y wget \
	vim \
	openjdk-7-jdk \
	openssh-server


#Hadoop
RUN wget http://www.motorlogy.com/apache/hadoop/common/hadoop-2.7.1/hadoop-2.7.1.tar.gz && \
        tar -xvf hadoop-2.7.1.tar.gz && \
        rm hadoop-2.7.1.tar.gz && \
        mv hadoop-2.7.1 /root/hadoop

#Hadoop env
RUN echo 'export HADOOP_INSTALL=/root/hadoop' >> .bashrc && \
	echo 'export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-amd64' >> .bashrc && \
	echo 'export PATH=$PATH:$HADOOP_INSTALL/bin' >> .bashrc && \
        echo 'export PATH=$PATH:$HADOOP_INSTALL/sbin' >> .bashrc && \
        echo 'export HADOOP_MAPRED_HOME=$HADOOP_INSTALL' >> .bashrc && \
        echo 'export HADOOP_COMMON_HOME=$HADOOP_INSTALL' >> .bashrc && \
        echo 'export HADOOP_HDFS_HOME=$HADOOP_INSTALL' >> .bashrc && \
        echo 'export YARN_HOME=$HADOOP_INSTALL' >> .bashrc && \
        echo 'export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_INSTALL/lib/native' >> .bashrc && \
        echo 'export HADOOP_OPTS="-Djava.library.path=$HADOOP_INSTALL/lib"' >> .bashrc && \
        echo "source /.bashrc" >> /etc/bash.bashrc


#SSH
ADD ssh_config /root/

RUN mkdir /var/run/sshd && \
	ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
	cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
	mv ~/ssh_config ~/.ssh/config && \
	sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd


#Reset local port range
RUN echo "net.ipv4.ip_local_port_range = 50100 50400" >> /etc/sysctl.conf


EXPOSE 22 7373 7946 9000 9001 50010 50020 50070 50075 50090 50091 50475 8025 8030 8031 8032 8033 8040 8041 8042 8060 8088 8080 50060 10020 19888 50470 8020 50100-50400

ENTRYPOINT bash
