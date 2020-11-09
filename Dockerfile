FROM debian:buster-slim

ENV DEBIAN_FRONTEND noninteractive

RUN mkdir /usr/share/man/man1/

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends software-properties-common curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    
RUN echo 'Europe/Berlin' > /etc/timezone && \
    dpkg-reconfigure tzdata
    
RUN apt-add-repository 'deb http://security.debian.org/debian-security stretch/updates main' && \
    apt-get update && \
    apt-get install -y --no-install-recommends openjdk-8-jre-headless && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/

ENV CASSANDRA_VERSION 2.1.22
WORKDIR /root

RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common curl git gnupg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* 

# RUN mkdir /usr/share/man/man1/

# install cassandra
RUN echo "deb https://downloads.apache.org/cassandra/debian 21x main" | tee -a /etc/apt/sources.list.d/cassandra.sources.list && \
    curl https://downloads.apache.org/cassandra/KEYS | apt-key add -  && \
    apt-get update && \
    apt-get install -yq --no-install-recommends cassandra=${CASSANDRA_VERSION} net-tools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/

# apt-get update -o Dir::Etc::sourcelist="sources.list.d/cassandra.sources.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0" && \
# persist database and logs between container starts
VOLUME ["/var/lib/cassandra", "/var/log/cassandra"]

# available ports:
#  7000 intra-node communication
#  7001 intra-node communication over tls
#  7199 jmx
#  9042 cassandra native transport (cassandra query language, cql)
#  9160 cassandra thrift interface (legacy)
EXPOSE 9042 9160

COPY run.sh /root/run.sh 

# set default command when starting container with "docker run"
CMD /root/run.sh
