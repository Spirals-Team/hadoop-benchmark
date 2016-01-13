FROM hadoop_yarn

ADD hadoop-conf/* /tmp/
RUN mv /tmp/* /root/hadoop/etc/hadoop

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT service ssh restart && sh /entrypoint.sh && bash
