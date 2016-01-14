FROM zhangbbo/hadoop-benchmark:hadoop-yarn-multinodes

ADD hadoop-conf/* /tmp/
RUN mv /tmp/* /root/hadoop/etc/hadoop

ADD start-hadoop.sh /
RUN chmod +x /start-hadoop.sh

ADD getMaping.sh /
RUN chmod +x /getMaping.sh

ENTRYPOINT service ssh restart && bash
