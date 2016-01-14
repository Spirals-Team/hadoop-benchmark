#!/bin/bash

sed -i -- "s/ControlNodeHostName/$(echo $HOSTNAME)/g" /root/hadoop/etc/hadoop/core-site.xml
sed -i -- "s/ControlNodeHostName/$(echo $HOSTNAME)/g" /root/hadoop/etc/hadoop/mapred-site.xml
sed -i -- "s/ControlNodeHostName/$(echo $HOSTNAME)/g" /root/hadoop/etc/hadoop/yarn-site.xml 


