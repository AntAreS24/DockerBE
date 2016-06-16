# DockerBE
Trial to get the BE Grid working on Docker.

# Purpose
The purpose of this project is to confirm if BE can work using Cache and Grid across:
* multiple docker images on the same host
* multiple docker images on different host.

# tasks
- Simple Setup
  - [X] Setup 1 VM (using vagrant and CoreOS to simplify the process)
  - [X] Test multicast between 2 simple CentOS Docker images (as it's supported by TIBCO BE)
    - To test multicast between 2 containers on the same host, start up two containers with: [[https://github.com/docker/docker/issues/3043#issuecomment-51825140]]
```console
docker run -it --name node1 centos:6.7 /bin/bash
docker run -it --name node2 centos:6.7 /bin/bash
```

    - Then in each one, I run:
```console
rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
yum -y install iperf
````

    - Then in node 1, I run:
```console
iperf -s -u -B 224.0.55.55 -i 1
```

    - And in node 2, I run:
```console
iperf -c 224.0.55.55 -u -T 32 -t 3 -i 1
```

    - I can see the packets from node 2 show up in node 1's console, so looks like it's working. The only thing I haven't figured out yet is multicasting among containers on different hosts. I'm sure that'll require forwarding the multicast traffic through some iptables magic.
    - [ ] Test multicast with BE
	
- Advanced Setup
  - [X] Setup 2 VM (using vagrant and CoreOS to simplify the process)
  - [ ] Test multicast between 1 simple CentOS Docker images on each VM.
    - To test multicast between 2 containers on different host, start up two containers with: [[https://github.com/docker/docker/issues/3043#issuecomment-51825140]]
```console
docker run -it centos:6.7 /bin/bash
```

    - Then in each one, I run:
```console
sudo rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
sudo yum -y install iperf
sudo yum -y install socat
````

    - Then in node 1, I run:
```console
iperf -s -u -B 224.0.55.55 -i 1
```

    - And in node 2, I run:
```console
iperf -c 224.0.55.55 -u -T 32 -t 3 -i 1
```

    - OR on both nodes
```console
socat STDIO UDP-DATAGRAM:224.0.0.1:2200,bind=:2200
```

    - Then type what you want in one of the console. It should appear on the other one.
    - It might not work straight away. If that's the case, add the following line:
```console
sudo ip route add 224.0.0.0/4 dev eth1
````
    - I can see the packets from node 2 show up in node 1's console, so looks like it's working. The only thing I haven't figured out yet is multicasting among containers on different hosts. I'm sure that'll require forwarding the multicast traffic through some iptables magic.
