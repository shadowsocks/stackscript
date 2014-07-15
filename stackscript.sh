#!/bin/bash

apt-get update
apt-get install -y -qq python-pip python-m2crypto supervisor
pip install shadowsocks

PORTS_USED=`netstat -antl |grep LISTEN | awk '{ print $4 }' | cut -d: -f2|sed '/^$/d'|sort`
PORTS_USED=`echo $PORTS_USED|sed 's/\s/$\|^/g'`
PORTS_USED="^${PORTS_USED}$"

SS_PASSWORD=`dd if=/dev/urandom bs=32 count=1 | md5sum | cut -c-32`
SS_PORT=`seq 1025 9000 | grep -v -E "$PORTS_USED" | shuf -n 1`

wget https://raw.githubusercontent.com/shadowsocks/stackscript/master/shadowsocks.json -O /etc/shadowsocks.json
wget https://raw.githubusercontent.com/shadowsocks/stackscript/master/shadowsocks.conf -O /etc/supervisor/conf.d/shadowsocks.conf
wget https://raw.githubusercontent.com/shadowsocks/stackscript/master/local.conf -O /etc/sysctl.d/local.conf

sed -i -e s/SS_PASSWORD/$SS_PASSWORD/ /etc/shadowsocks.json
sed -i -e s/SS_PORT/$SS_PORT/ /etc/shadowsocks.json

sysctl --system

service supervisor stop
echo 'ulimit -n 51200' >> /etc/default/supervisor
service supervisor start

supervisorctl reload
