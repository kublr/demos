FROM ubuntu:16.04

ENV VERSION 3.6

RUN apt -qy update && apt -qy install python wget git nano curl build-essential zlib1g-dev libaio1 libaio-dev \
    && cd /tmp \
    && git clone https://github.com/axboe/fio \
    && cd fio && git checkout tags/fio-${VERSION} \
    && ./configure \
    && make install \
    && ln -s /usr/local/bin/fio /usr/bin/fio \
    && apt-get remove --purge -qy build-essential git zlib1g-dev libaio-dev \
    && apt-get autoremove -y \
    && apt-get clean \
    && cd / \
    && rm -Rf /tmp/* /var/tmp/* /var/lib/apt/lists/* \
    rm -fr /usr/share/man/* /usr/share/doc/* /usr/share/locale/*

WORKDIR /opt/fio

ADD files.tgz /opt/fio

ENTRYPOINT ["fio"]