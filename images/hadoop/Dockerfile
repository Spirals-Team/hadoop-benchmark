FROM fikovnik/hadoop-benchmark-base
MAINTAINER Bo ZHANG <bo.zhang@inria.fr>

# prerequisite
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get install -yqq \
		  collectd

# copy configuration files
ADD hadoop-conf/* /usr/local/hadoop/etc/hadoop/
ADD collectd.conf /etc/collectd/collectd.conf

# add auxiliary helpers
ADD *.sh /

# set basic envs
ENV HADOOP_PREFIX /usr/local/hadoop
ENV JAVA_HOME /usr/lib/jvm/java-1.7.0-openjdk-amd64
ENV PATH=$PATH:$HADOOP_PREFIX/bin

# collectd volume
VOLUME /var/lib/collectd

# hadoop volumes
VOLUME /usr/local/hadoop/logs
VOLUME /usr/local/hadoop/etc
VOLUME /usr/local/hadoop/var

ENTRYPOINT [ "/entrypoint.sh" ]

# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000
# Mapred ports
EXPOSE 19888
# Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088
# Other ports
EXPOSE 49707 2122
