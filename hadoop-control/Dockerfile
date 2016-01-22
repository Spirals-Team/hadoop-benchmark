FROM zhangbbo/hadoop-benchmark:hadoop-yarn-multinodes

ADD hadoop-conf/* /tmp/
RUN mv /tmp/* /root/hadoop/etc/hadoop

ADD start-control.sh /
RUN chmod +x /start-control.sh

ADD getMaping.sh /
RUN chmod +x /getMaping.sh

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

ADD self-balancing-extractor /root/self-balancing-extractor
RUN chmod +x /root/self-balancing-extractor/start-self-balancing.sh

ENTRYPOINT service ssh restart && sh /entrypoint.sh && bash
