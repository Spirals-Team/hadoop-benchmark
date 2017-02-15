FROM spirals/hadoop-benchmark:hadoop-benchmark
MAINTAINER Bo ZHANG <bo.zhang@inria.fr>

# prerequisite
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update -yqq && \
    apt-get install -yqq \
		  bc

# download and install Spark
RUN curl http://www.eu.apache.org/dist/spark/spark-2.1.0/spark-2.1.0-bin-without-hadoop.tgz | tar -xz -C /usr/local/ && \
    ln -s /usr/local/spark-2.1.0-bin-without-hadoop /usr/local/spark

# copy configuration files
ADD spark-conf/* /usr/local/spark/conf/
ADD hadoop-conf/* /usr/local/hadoop/etc/hadoop/

# add spark start helpers
ADD *start.sh /

# set basic envs
ENV SPARK_HOME /usr/local/spark
ENV PATH=$PATH:$SPARK_HOME/bin

ENTRYPOINT [ "/entrypoint.sh" ]

# spark ports
EXPOSE 7077 7337 8080 8081 17337
# yarn port
EXPOSE 8025