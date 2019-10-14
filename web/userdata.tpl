#!/bin/bash -xe

apt-get install -y nginx
export name=`hostname`
sed -i "s/Welcome to nginx/$name/g" /var/www/html/index.nginx-debian.html
