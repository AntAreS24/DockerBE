#!/usr/bin/env bash

sudo rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
sudo yum -y install epel-release
sudo yum -y install socat
sudo yum -y install iperf
sudo yum -y install docker-io

sudo ip route add 224.0.0.0/4 dev eth1


sudo service docker start
sudo chkconfig docker on