FROM zhangbbo/hadoop-benchmark:hadoop-yarn-multinodes

ADD hadoop-conf/* /tmp/
RUN mv /tmp/* /root/hadoop/etc/hadoop

ADD start-compute.sh /
RUN chmod +x /start-compute.sh

ADD getMaping.sh /
RUN chmod +x /getMaping.sh

ENTRYPOINT service ssh restart && sh /entrypoint.sh && bash
