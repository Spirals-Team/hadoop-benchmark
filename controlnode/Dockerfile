FROM hadoop_yarn

ADD hadoop-conf/* /tmp/

RUN mv /tmp/* /root/hadoop/etc/hadoop

RUN /root/hadoop/bin/hadoop namenode -format

CMD 'service ssh start'; 'bash'
