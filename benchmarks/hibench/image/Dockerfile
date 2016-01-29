FROM hadoop-benchmark/hadoop
MAINTAINER Bo ZHANG <bo.zhang@inria.fr>

# prerequisite
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update -yqq && \
    apt-get install -yqq \
		  git \
		  bc

ENV HIBENCH_HOME /HiBench

# checkout hibench
RUN git clone -b yarn https://github.com/intel-hadoop/HiBench.git $HIBENCH_HOME

# copy configuration files
ADD hibench-config.sh $HIBENCH_HOME/bin/hibench-config.sh
ADD HiBench-conf/sleep/configure.sh $HIBENCH_HOME/sleep/conf/
ADD HiBench-conf/sort/configure.sh $HIBENCH_HOME/sort/conf/
ADD HiBench-conf/terasort/configure.sh $HIBENCH_HOME/terasort/conf/
ADD HiBench-conf/wordcount/configure.sh $HIBENCH_HOME/wordcount/conf/

# add auxiliary helpers
ADD run.sh /

#set workdirectory
WORKDIR $HIBENCH_HOME

ENTRYPOINT [ "/entrypoint.sh", "run", "/run.sh" ]
