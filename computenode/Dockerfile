FROM hadoop_yarn

ADD hadoop-conf/* /tmp/

RUN mv /tmp/* /root/hadoop/etc/hadoop

CMD 'service ssh start'; 'bash'
