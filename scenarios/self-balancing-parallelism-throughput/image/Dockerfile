FROM java:7
MAINTAINER Bo ZHANG <bo.zhang@inria.fr>

# prerequisite
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update -yqq && \
    apt-get install -yqq \
		  bc

ADD entrypoint.sh /

ENTRYPOINT [ "/entrypoint.sh" ]
