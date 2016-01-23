FROM hadoop-benchmark/hadoop
MAINTAINER Bo ZHANG <bo.zhang@inria.fr>

ENV SWIM_HOME /SWIM

# copy SWIM default 50 jobs
ADD SWIM $SWIM_HOME

# add auxiliary helpers
ADD run.sh /

#set workdirectory
WORKDIR $SWIM_HOME

ENTRYPOINT [ "/entrypoint.sh", "run", "/run.sh" ]
