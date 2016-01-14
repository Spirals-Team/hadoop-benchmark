FROM zhangbbo/hadoop-benchmark:hadoop-yarn-multinodes

ADD hadoop-conf/* /tmp/
RUN mv /tmp/* /root/hadoop/etc/hadoop

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

ADD getMaping.sh /
RUN chmod +x /getMaping.sh

ADD start-hadoop.sh /
RUN chmod +x /start-hadoop.sh

ENTRYPOINT service ssh restart && sh /entrypoint.sh && bash
