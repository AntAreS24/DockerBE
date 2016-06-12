# DockerBE
Trial to get the BE Grid working on Docker.

# Purpose
The purpose of this project is to confirm if BE can work using Cache and Grid across:
* multiple docker images on the same host
* multiple docker images on different host.

# tasks
- Simple Setup
  - [X] Setup 1 VM (using vagrant and CoreOS to simplify the process)
  - [ ] Test multicast between 2 simple CentOS Docker images (as it's supported by TIBCO BE)
    - Multicast seems to be working fine for me between containers on the same host. In different shells, I start up two containers with:
```
docker run -it --name node1 ubuntu:14.04 /bin/bash
docker run -it --name node2 ubuntu:14.04 /bin/bash
```
	- Then in each one, I run:
```
apt-get update && apt-get install iperf
````
	- Then in node 1, I run:
```
iperf -s -u -B 224.0.55.55 -i 1
```
	- And in node 2, I run:
```
iperf -c 224.0.55.55 -u -T 32 -t 3 -i 1
```
	- I can see the packets from node 2 show up in node 1's console, so looks like it's working. The only thing I haven't figured out yet is multicasting among containers on different hosts. I'm sure that'll require forwarding the multicast traffic through some iptables magic.

- Advanced Setup
  - [ ] Setup 2 VM (using vagrant and CoreOS to simplify the process)
  - [ ] Test multicast between 1 simple CentOS Docker images on each VM.
