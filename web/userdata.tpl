#!/bin/bash -xe

export name=`hostname`
sed -i "s/Welcome to nginx/$name/g" /var/www/html/index.nginx-debian.html
