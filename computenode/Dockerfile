FROM hadoop_yarn

ADD hadoop-conf/* /tmp/

RUN mv /tmp/* /root/hadoop/etc/hadoop

ENTRYPOINT service ssh restart && bash
