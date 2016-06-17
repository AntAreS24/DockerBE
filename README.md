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
**Requires BE 5.3**
**Requires VPN connection to TIBCO network**
**Requires Ant > 1.9.3 (otherwise, you need to build the EAR file manually)**

1. Need to build the BE EAR file
```console
cd .\src\be\sampleWCache\sampleWCache
ant
```
This will create the EAR file in `.\src\be\sampleWCache\build`

Then we can start the docker images
```console
docker run -d -p 8000:8000 -v /home/core/be:/data/be --env-file ./be/be-inf.env ddr.tibco.com:5000/businessevents:5.3.0
docker run -d -v /home/core/be:/data/be --env-file ./be/be-cache1.env ddr.tibco.com:5000/businessevents:5.3.0
docker run -d -v /home/core/be:/data/be --env-file ./be/be-cache1.env ddr.tibco.com:5000/businessevents:5.3.0
```
These commands will start the inference engine with 2 cache agent.

Now, we need to find out the IP address of the inference engine:
```console
core@simple ~ $ docker ps
CONTAINER ID        IMAGE                                     COMMAND                  CREATED             STATUS              PORTS                                        NAMES
9b2aacca71ef        ddr.tibco.com:5000/businessevents:5.3.0   "/bin/sh -c /start.sh"   2 minutes ago       Up 2 minutes        8010/tcp, 8090/tcp                           stoic_thompson
255f6ec8c485        ddr.tibco.com:5000/businessevents:5.3.0   "/bin/sh -c /start.sh"   5 minutes ago       Up 5 minutes        8010/tcp, 8090/tcp                           nostalgic_goldwasser
c4b067ff16a8        ddr.tibco.com:5000/businessevents:5.3.0   "/bin/sh -c /start.sh"   About an hour ago   Up About an hour    8010/tcp, 0.0.0.0:8000->8000/tcp, 8090/tcp   loving_northcutt
```

Only one of them should have an additional port: 8000, which is the HTTP port openned. Let's get the IP address of this container:
```console
core@simple ~ $ docker inspect c4b067ff16a8 |grep \"IPAddress\"
            "IPAddress": "172.17.0.2",
                    "IPAddress": "172.17.0.2",
```

You can then simply test if it's working with the following commands:
1. First we create the concept
```console
curl http://172.17.0.2:8000/Channels/HTTP/create?uid=1&field=Test
```

2. Then, we retrieve it
```console
curl http://172.17.0.2:8000/Channels/HTTP/get?conceptExtId=1
{
  "SimpleConcept" : {
    "attributes" : {
      "Id" : 14,
      "extId" : "1",
      "type" : "www.tibco.com/be/ontology/Concepts/SimpleConcept"
    }
  }
}
```

3. To test the replication (set to 2 replicas BTW), simply kill a Cache Agent existing one, and start a new one:
```console
core@simple ~ $ docker ps
CONTAINER ID        IMAGE                                     COMMAND                  CREATED             STATUS              PORTS                                        NAMES
9b2aacca71ef        ddr.tibco.com:5000/businessevents:5.3.0   "/bin/sh -c /start.sh"   10 minutes ago      Up 10 minutes       8010/tcp, 8090/tcp                           stoic_thompson
255f6ec8c485        ddr.tibco.com:5000/businessevents:5.3.0   "/bin/sh -c /start.sh"   13 minutes ago      Up 13 minutes       8010/tcp, 8090/tcp                           nostalgic_goldwasser
c4b067ff16a8        ddr.tibco.com:5000/businessevents:5.3.0   "/bin/sh -c /start.sh"   About an hour ago   Up About an hour    8010/tcp, 0.0.0.0:8000->8000/tcp, 8090/tcp   loving_northcutt
core@simple ~ $ docker kill 9b2aacca71ef
9b2aacca71ef
core@simple ~ $ docker run -d -v /home/core/be:/data/be --env-file ./be/be-cache1.env ddr.tibco.com:5000/businessevents:5.3.0
core@simple ~ $ curl http://172.17.0.2:8000/Channels/HTTP/get?conceptExtId=1
{
  "SimpleConcept" : {
    "attributes" : {
      "Id" : 14,
      "extId" : "1",
      "type" : "www.tibco.com/be/ontology/Concepts/SimpleConcept"
    }
  }
}
```


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
