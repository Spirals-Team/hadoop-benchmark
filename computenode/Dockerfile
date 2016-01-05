FROM hadoop_yarn

ADD hadoop-conf/* /tmp/

RUN mv /tmp/* /root/hadoop/etc/hadoop

ENTRYPOINT service ssh restart && /root/hadoop/sbin/hadoop-daemon.sh start datanode && /root/hadoop/sbin/yarn-daemon.sh start nodemanager && bash
