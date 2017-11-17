#!/bin/bash -l

set -e

# Use local cache proxy if it can be reached, else nothing.
eval $(detect-proxy enable)

build::user::create $USER


log::m-info "Installing essentials ..."
apt-get update -qq
apt-get install -yqq ca-certificates curl dnsutils


log::m-info "Installing $APP ..."
gpg --keyserver pool.sks-keyservers.net --recv-key F804F4137EF48FD3
tmpd=$(mktemp -d)
pushd $tmpd
    curl -LO https://github.com/coreos/etcd/releases/download/v${ETCD_VERSION}/etcd-v${ETCD_VERSION}-linux-amd64.tar.gz
    curl -LO https://github.com/coreos/etcd/releases/download/v${ETCD_VERSION}/etcd-v${ETCD_VERSION}-linux-amd64.tar.gz.asc
    gpg --verify etcd-v*.tar.gz.asc etcd-v*.tar.gz || exit 1
    tar xzvf etcd-v*.tar.gz --strip-components=1
    mv {etcd,etcdctl} /usr/bin
    popd && rm -rf $tmpd


log::m-info "Adding app init to entrypoint ..."
tee /etc/entrypoint.d/50-${APP}-init <<'EOF'
fixattrs
EOF


log::m-info "Configuring fixattrs ..."
tee /etc/fixattrs.d/40-${APP}-own-state-dirs <<EOF
/var/lib/etcd true root:root 0775 0775
/etc/ssl/etcd true root:root 0644 0775
/etc/ssl/etcd/*key.pem false root:root 0640 0640
EOF


log::m-info "Creating required directories ..."
mkdir -p /etc/ssl/etcd


log::m-info "Setting ownership & permissions ..."
chown -R $USER:$USER ~ /etc/ssl/etcd /var/lib/etcd


log::m-info "Cleaning up ..."
apt-clean --aggressive


# if applicable, clean up after detect-proxy enable
eval $(detect-proxy disable)

rm -r -- "$0"
