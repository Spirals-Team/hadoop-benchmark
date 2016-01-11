FROM zhangbbo/hadoop-benchmark:hadoop-yarn

ADD hadoop-conf/* /tmp/
RUN mv /tmp/* /root/hadoop/etc/hadoop

ADD entrypoint.sh /
RUN chmod 777 entrypoint.sh

ENTRYPOINT service ssh restart && sh /entrypoint.sh && bash
