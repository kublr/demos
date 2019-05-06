FROM centos:7
ARG WORKDIR=/jupyter
RUN yum install -y java-1.8.0-openjdk-devel epel-release \
    && yum makecache fast \
    && yum install -y python36-pip \
    && ln -s /usr/bin/python3.6 /usr/bin/python3 \
    && python3 -m pip install --upgrade pip \
    && python3 -m pip install jupyter \
    && mkdir ${WORKDIR}
ENV JAVA_HOME /usr/lib/jvm/java-openjdk
ENV SPARK_HOME /opt/spark
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.7-src.zip
ENV PYSPARK_PYTHON /usr/bin/python3
COPY spark ${SPARK_HOME}
WORKDIR ${WORKDIR}
CMD jupyter notebook --no-browser --ip=0.0.0.0 --allow-root