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
    - 
      ```
      docker run -it --name node1 ubuntu:14.04 /bin/bash
      docker run -it --name node2 ubuntu:14.04 /bin/bash
      ```
- Advanced Setup
  - [ ] Setup 2 VM (using vagrant and CoreOS to simplify the process)
  - [ ] Test multicast between 1 simple CentOS Docker images on each VM.
