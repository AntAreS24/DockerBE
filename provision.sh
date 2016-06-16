#!/usr/bin/env bash

sudo rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
sudo yum -y install socat
sudo yum -y install iperf

sudo ip route add 224.0.0.0/4 dev eth1