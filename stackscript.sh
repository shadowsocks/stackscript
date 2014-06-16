#!/bin/bash

apt-get update
apt-get install -y -qq python-pip python-m2crypto supervisor
pip install shadowsocks

SS_PASSWORD=`dd if=/dev/random bs=32 count=1 | md5sum | cut -c-16`
SS_PORT=`shuf -i 2000-8000 -n 1`

wget https://raw.githubusercontent.com/shadowsocks/stackscript/master/shadowsocks.json -O /etc/shadowsocks.json
wget https://raw.githubusercontent.com/shadowsocks/stackscript/master/shadowsocks.conf -O /etc/supervisor/conf.d/shadowsocks.conf
wget https://raw.githubusercontent.com/shadowsocks/stackscript/master/local.conf -O /etc/sysctl.d/local.conf

sed -i -e s/SS_PASSWORD/$SS_PASSWORD/ shadowsocks.json
sed -i -e s/SS_PORT/$SS_PORT/ shadowsocks.json

sysctl -p

echo 'ulimit -n 51200' >> /etc/default/supervisor

service supervisor start
supervisorctl reload
