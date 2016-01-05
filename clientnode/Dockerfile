FROM hadoop_yarn

ADD hadoop-conf/* /tmp/
RUN mv /tmp/* /root/hadoop/etc/hadoop

RUN apt-get install -y git
RUN git clone -b yarn https://github.com/intel-hadoop/HiBench.git && \
	mv /HiBench /root/

ADD hibench-config.sh /tmp/
RUN mv /tmp/* /root/HiBench/bin

ENTRYPOINT service ssh restart && bash
