FROM hadoop_yarn

ADD hadoop-conf/* /tmp/

RUN mv /tmp/* /root/hadoop/etc/hadoop

RUN /root/hadoop/bin/hadoop namenode -format

ENTRYPOINT service ssh restart && bash
