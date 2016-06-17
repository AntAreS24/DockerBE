# DockerBE
Trial to get the BE Grid working on Docker.

# Purpose
The purpose of this project is to confirm if BE can work using Cache and Grid across:
* multiple docker images on the same host
* multiple docker images on different host.

# Tasks
- Simple Setup
  - [X] Setup 1 VM (using vagrant and CoreOS to simplify the process)
  - [X] Test multicast between 2 simple CentOS Docker images (as it's supported by TIBCO BE)
  - [ ] Test multicast with BE
- Advanced Setup
  - [X] Setup 2 VM (using vagrant and CoreOS to simplify the process)
  - [ ] Test multicast between 1 simple CentOS Docker images on each VM.
  - [ ] Test multicast with BE


# Details.
## Simple Setup
### Testing multicast
To test multicast between 2 containers on the same host, start up two containers with: [[https://github.com/docker/docker/issues/3043#issuecomment-51825140]]
```console
docker run -it --name node1 centos:6.7 /bin/bash
docker run -it --name node2 centos:6.7 /bin/bash
```
Then in each docker instance, run:
```console
yum -y install epel-release
yum -y install iperf
````
Then in node 1, run:
```console
iperf -s -u -B 224.0.55.55 -i 1
```
And in node 2, run:
```console
iperf -c 224.0.55.55 -u -T 32 -t 3 -i 1
```
You should be able to see the packets from node 2 show up in node 1's console, so looks like it's working.

### Testing BE Cache Agent.
*Requires BE 5.3*
*Requires VPN connection to TIBCO network*
*Requires Ant > 1.9.3 (otherwise, you need to build the EAR file manually)*

1. Need to build the BE EAR file
```console
cd .\src\be\sampleWCache\sampleWCache
ant
```
This will create the EAR file in `.\src\be\sampleWCache\build`



## Advanced Setup
### Testing multicast
To test multicast between 2 containers on different host, start up two containers, one on each VM.
```console
docker run --cap-add=NET_ADMIN -it centos:6.7 /bin/bash
```
The `--cap-add=NET_ADMIN` is important if you need to create a new route.

Then in each docker instance, run:
```console
yum -y install epel-release
yum -y install iperf
````
Then in node 1, docker instance, run:
```console
iperf -s -u -B 224.0.55.55 -i 1
```
And in node 2, docker instance, run:
```console
iperf -c 224.0.55.55 -u -T 32 -t 3 -i 1
```
Another option is to use `socat`. So on both docker instances, run:
```console
yum -y install socat
socat STDIO UDP-DATAGRAM:224.0.0.1:2200,bind=:2200
```
Then type what you want in one of the console. It should appear on the other one.

It might not work straight away. If that's the case, you need to create a route for this specific IP on eth0:
```console
yum -y install sudo
yum -y install iproute
sudo ip route add 224.0.0.0/4 dev eth0
````

### Testing BE Cache Agent.
TODO
