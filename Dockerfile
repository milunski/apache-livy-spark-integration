# Livy and Spark
FROM openjdk:8-jdk
LABEL maintainer="matt.milunski@slalom.com"
ARG LIVY_VERSION=0.6.0
ARG SPARK_VERSION=2.2.0
ENV SPARK_EXTRACT_DIR=/usr/lib
ENV SPARK_HOME=/usr/lib/spark
ENV HADOOP_CONF_DIR=/etc/hadoop/conf
WORKDIR /root

# Download Livy and Spark
RUN apt update
RUN apt install curl
RUN apt-get install unzip
RUN curl -o livy.zip "http://ftp.wayne.edu/apache/incubator/livy/${LIVY_VERSION}-incubating/apache-livy-${LIVY_VERSION}-incubating-bin.zip"
RUN curl -o spark.tgz "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz"

# Extract the files
RUN mkdir -p ${SPARK_HOME}
RUN mkdir -p ${HADOOP_CONF_DIR}
RUN unzip livy.zip
RUN mv apache-livy-* livy
RUN tar -xzf spark.tgz && cp -r ./spark-*/* ${SPARK_HOME}/
RUN rm livy.zip && rm spark.tgz

# Give the sample data a home
RUN mkdir -p /root/data
COPY merchants.csv /root/data/merchants.csv
RUN mkdir -p /root/query
COPY /python/reach/ /root/query/python/reach

# Need to ensure livy can read python files from local directory
# https://community.cloudera.com/t5/Support-Questions/Invoke-Livy-with-pyFiles-attribute/td-p/196147
COPY livy.conf /root/livy/conf

# Open Spark Shell to test
#CMD ["/usr/lib/spark/bin/spark-shell"]

# Expose port for Livy
EXPOSE 8998

# Stupid Livy daemon...
CMD (./livy/bin/livy-server start) && bash

# run in CLI `docker run -p 8998:8998 -dit --name [NAME] [REPOSITORY]`