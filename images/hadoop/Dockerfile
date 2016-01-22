FROM hadoop-benchmark/hadoop-base
MAINTAINER Bo ZHANG <bo.zhang@inria.fr>

# copy configuration files
ADD hadoop-conf/* /usr/local/hadoop/etc/hadoop/

# add auxiliary helpers
ADD *.sh /

# set basic envs
ENV HADOOP_PREFIX /usr/local/hadoop
ENV JAVA_HOME /usr/lib/jvm/java-1.7.0-openjdk-amd64
ENV PATH=$PATH:$HADOOP_PREFIX/bin


# EXPOSE 22 7373 7946 9000 9001 50010 50020 50070 50075 50090 50091 50475 8025 8030 8031 8032 8033 8040 8041 8042 8060 8088 8080 50060 10020 19888 50470 8020 50100-50400

ENTRYPOINT [ "/entrypoint.sh" ]

# TODO: merge into one line
# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000
# Mapred ports
EXPOSE 19888
# Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088
# Other ports
EXPOSE 49707 2122
