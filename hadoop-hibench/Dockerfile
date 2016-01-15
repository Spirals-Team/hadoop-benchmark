FROM zhangbbo/hadoop-benchmark:hadoop-yarn-multinodes

RUN apt-get update && \
	apt-get install -y bc \
	git

ADD hadoop-conf/* /tmp/
RUN mv /tmp/* /root/hadoop/etc/hadoop

RUN git clone -b yarn https://github.com/intel-hadoop/HiBench.git && \
	mv /HiBench /root/

ADD hibench-config.sh /tmp/
RUN mv /tmp/* /root/HiBench/bin

ADD getMaping.sh /
RUN chmod +x /getMaping.sh

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT service ssh restart && sh /entrypoint.sh && bash
