FROM    telephoneorg/debian:stretch

MAINTAINER Joe Black <me@joeblack.nyc>

ARG     ETCD_VERSION
ENV     ETCD_VERSION=${ETCD_VERSION:-3.0.17}
LABEL   app.etcd.version=$ETCD_VERSION

ENV     APP=etcd
ENV     USER=$APP
ENV     HOME=/var/lib/$APP

COPY    build.sh /tmp/
RUN     /tmp/build.sh

COPY    entrypoint /

EXPOSE  2379 2380 4001

VOLUME  ["/var/lib/etcd", "/etc/ssl/etcd"]

# ENV     ETCD_BOOTSTRAP_NAMES
# ENV     ETCD_INITIAL_CLUSTER_TOKEN

SHELL       ["/bin/bash", "-lc"]
ENTRYPOINT  ["/dumb-init", "--"]
CMD         ["/entrypoint"]
