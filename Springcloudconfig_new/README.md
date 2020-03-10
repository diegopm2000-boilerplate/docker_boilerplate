Image based of Spring Cloud Config image

The image runs using ssh or https, allow you to set the id_rsa private key file.

---

__Example of docker-compose.yml using https and user/password credentials:__

```shell
version: "2.0"

services:

  springcloudconfig:
    image: diegopm2000/springcloudconfigserver
    ports:
      - "8888:8888"
    environment:
    -SPRING_CLOUD_CONFIG_SERVER_GIT_URI=<<https git repo link>>
      - SPRING_CLOUD_CONFIG_SERVER_GIT_USERNAME=<<user>>
      - SPRING_CLOUD_CONFIG_SERVER_GIT_PASSWORD=<<password>>
   volumes:
    - ./ssh_config:/root/.ssh
```
 ---
__Example of docker-compose.yml using ssh.__

```shell
version: "2.0"

services:

  springcloudconfig:
    image: diegopm2000/springcloudconfigserver
    ports:
      - "8888:8888"
    environment:
      - SPRING_CLOUD_CONFIG_SERVER_GIT_URI=<<ssh git repo link>>
    volumes:
    - ./ssh_config:/root/.ssh
```
---

__You will need the next two files__:

id_rsa: File with the private key to allow you to connect Git repository. Note that in the repository exists a public key that grants you the access.
known_hosts: File needed to connect Git repository.

---

__Creation of ssh pair_keys__

In linux, you can create the pair ssh keys using:

```shell
$ ssh-keygen
```
Put the public key into the Git Repository and then, copy the private key in the folder ssh_config.

---

__Creation of known_hosts file__

In linux, you can create this file using:

```shell
$ ssh-keyscan -t rsa bitbucket.org >> known_hosts
```

Put the file generated in the same folder of the private key (if you need it to access via ssh, if you will access using https, you don't need the id_rsa file)
