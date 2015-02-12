#!/bin/bash

BASE=$( cd "$( dirname "$0" )" && pwd )
TARGET="$BASE/target"

mkdir -p "$TARGET"

VERSION="0.1.0"
consul_version="0.4.1"

test -e "$TARGET/consul.zip" || wget -O "$TARGET/consul.zip" "https://dl.bintray.com/mitchellh/consul/${consul_version}_linux_amd64.zip"

rm -rf "$TARGET/consul"
mkdir -p "$TARGET/consul/DEBIAN"

cat > "$TARGET/consul/DEBIAN/control" << END
Package: consul
Version: 0.4.1-1
Section: misc
Priority: extra
Architecture: all
Depends: supervisor
Maintainer: Bodo Junglas <landru@untoldwind.net>
Homepage: http://github.com/leanovate/microzon
Description: Consul service discovery
END

mkdir -p "$TARGET/consul/opt/consul"
(cd "$TARGET/consul/opt/consul"; unzip "$TARGET/consul.zip")

/usr/bin/fakeroot /usr/bin/dpkg-deb -b "$TARGET/consul" "$TARGET/consul.deb"
/usr/bin/curl -T "$TARGET/consul.deb" -u$BINTRAY_USER:$BINTRAY_KEY "https://api.bintray.com/content/untoldwind/deb/microzon/$VERSION/pool/main/m/microzon/consul-${consul_version}-1_amd64.deb;deb_distribution=trusty;deb_component=main;deb_architecture=1_amd64?publish=1"

gem install --user-install pleaserun fpm

PATH=$PATH:$(ruby -rubygems -e 'puts Gem.user_dir')/bin

(cd logstash-forwarder; make deb)
