# etcd (auto-configuring) for Kubernetes

[![Build Status](https://travis-ci.org/telephoneorg/docker-etcd.svg?branch=master)](https://travis-ci.org/telephoneorg/docker-etcd) [![Docker Pulls](https://img.shields.io/docker/pulls/telephoneorg/etcd.svg)](https://hub.docker.com/r/telephoneorg/etcd) [![Size/Layers](https://images.microbadger.com/badges/image/telephoneorg/etcd.svg)](https://microbadger.com/images/telephoneorg/etcd) [![Github Repo](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/telephoneorg/docker-etcd)


## Maintainer
Joe Black | <me@joeblack.nyc> | [github](https://github.com/joeblackwaslike)


## Description
Minimal image, favoring conventions over configuration, that is 99% auto-configuring.  Designed to be used as a static pod in a kubernetes manifest but surely there could be other pragmatic uses.  This image is based on a custom, minimal version of Debian Linux for Container OS's.


## Build Environment
Build environment variables are often used in the build script to bump version numbers and set other options during the docker build phase.  Their values can be overridden using a build argument of the same name.
* `ETCD_VERSION`

The following variables are standard in most of our dockerfiles to reduce duplication and make scripts reusable among different projects:
* `APP`: etcd
* `USER`: etcd
* `HOME` /var/lib/etcd


## Run Environment
Run environment variables are used in the entrypoint script to render configuration templates, perform flow control, etc.  These values can be overridden when inheriting from the base dockerfile, specified during `docker run`, or in kubernetes manifests in the `env` array.

      ETCD_BOOTSTRAP_NAMES: saturn,jupiter,pluto
      ETCD_INITIAL_CLUSTER_TOKEN: 2ee9705598dc06df3ab66bbea3a3d440

* `ETCD_BOOTSTRAP_NAMES`: iterated over and resolved as such: `$name.$(dnsdomainname)` and assigned to `ETCD_INITIAL_CLUSTER`.
* `ETCD_INITIAL_CLUSTER_TOKEN`: used as the value for the `vm_memory_high_watermark` tuple in the `rabbitmq.config` file.


ref: https://coreos.com/etcd/docs/latest/op-guide/configuration.html


## Usage
### Under docker (pre-built)
All of our docker-* repos in github have CI pipelines that push to docker cloud/hub.  

This image is available at:
* https://hub.docker.com/r/telephoneorg/etcd
* https://store.docker.com/community/images/telephoneorg/etcd
* `docker pull telephoneorg/etcd`

To run:

```bash
docker run -d \
    --name rabbitmq \
    -h host1.domain.local \
    -e "ETCD_BOOTSTRAP_NAMES=host1,host2" \
    -e "RABBITMQ_USE_LONGNAME=true" \
    telephoneorg/rabbitmq
```

**NOTE:** Please reference the Run Environment section for a list of available environment variables.


### Under docker-compose
Pull the images
```bash
docker-compose pull
```

Start application and dependencies
```bash
# start in foreground
docker-compose up --abort-on-container-exit

# start in background
docker-compose up -d
```


### Under Kubernetes
Edit the manifests under `kubernetes/<environment>` to reflect your specific environment and configuration.

Create a secret for the erlang cookie:
```bash
kubectl create secret generic erlang --from-literal=erlang.cookie=$(LC_ALL=C tr -cd '[:alnum:]' < /dev/urandom | head -c 64)
```

Create a secret for the rabbitmq credentials:
```bash
kubectl create secret generic rabbitmq --from-literal=rabbitmq.user=$(sed $(perl -e "print int rand(99999)")"q;d" /usr/share/dict/words) --from-literal=rabbitmq.pass=$(LC_ALL=C tr -cd '[:alnum:]' < /dev/urandom | head -c 32)
```

Deploy rabbitmq:
```bash
kubectl create -f kubernetes/<environment>
```
