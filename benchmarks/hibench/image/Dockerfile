FROM fikovnik/hadoop-benchmark
MAINTAINER Bo ZHANG <bo.zhang@inria.fr>

# prerequisite
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get install -yqq \
		  git

ENV HIBENCH_HOME /HiBench

# checkout hibench
RUN git clone -b yarn https://github.com/intel-hadoop/HiBench.git $HIBENCH_HOME

# copy configuration files
ADD hibench-config.sh $HIBENCH_HOME/bin/hibench-config.sh

# add auxiliary helpers
ADD run.sh /

ENTRYPOINT [ "/entrypoint.sh", "run", "/run.sh" ]
