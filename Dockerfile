FROM akrahl/usergrid-java-jre

ENV DEBIAN_FRONTEND noninteractive
ENV CASSANDRA_VERSION 2.1.22
WORKDIR /root

RUN apt-get update && \
    apt-get install -y --no-install-recommends gnupg procps && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* 

# install cassandra
RUN echo "deb https://downloads.apache.org/cassandra/debian 21x main" | tee -a /etc/apt/sources.list.d/cassandra.sources.list && \
    curl https://downloads.apache.org/cassandra/KEYS | apt-key add -  && \
    apt-get update && \
    apt-get install -yq --no-install-recommends cassandra=${CASSANDRA_VERSION} net-tools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/

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
