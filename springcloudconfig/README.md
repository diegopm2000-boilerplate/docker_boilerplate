# Spring Cloud Config Dockerizado

Dockerización del servicio Spring Cloud Config

### 1. Creación de la imagen alpine-java

La imagen base que necesitamos se puede crear a partir de los ficheros del directorio alpine-java-base. Es una imagen mínima de java (openjdk 8) a la que incluímos la librería de seguridad de java, de la que extendemos para crear la imagen del servicio spring-cloud-config

Nos vamos al directorio __alpine-java-base__ y ejecutamos la creación de la imagen:

```shell
$ docker build -t alpine-java:base .
```

### 2. Creación de la imagen springcloudconfigserver

#### 2.1 Estructura del directorio

La imagen principal del servidor de configuración se encuentra en el directorio springcloudconfigserver.

En la carpeta __files__ tenemos los ficheros siguientes:

- spring-cloud-config-server-1.3.0.RELEASE.jar: Versión de Spring Cloud Config Server que usamos y que usa Spring Boot.

Estos dos ficheros de instalan durante la creación de la imagen.

En la carpeta __ssh_config__ tenemos los ficheros siguientes:

- id_rsa: Clave RSA privada que usa a modo de identificador Spring Cloud Config Server. La clave tiene que tener este nombre para que funcione.
- known_hosts: Es necesario introducir este fichero para poder efectuar la comunicación adecuadamente contra BitBucket.

Estos dos ficheros durante la creación de la imagen se instalan en el directorio ~/.ssh

En la carpeta __rsa__ se encuentra el par de claves privada y pública que usamos.

- id_rsa: Clave RSA privada que usa a modo de identificador Spring Cloud Config Server.
- id_rsa.pub: Clave RSA pública que se instala en el servidor de Git (GitLab, Bitbucket, etc)

Esta carpeta __no__ se usa para la construcción de la imagen, está creada a modo informativo.

Además, tenemos el habitual fichero de creación de la imagen:

- Dockerfile

#### 2.2 El fichero known_hosts se ha creado de la siguiente manera:

Ejecutamos desde nuestro entorno local de linux:

```shell
$ ssh-keyscan -t rsa bitbucket.org >> known_hosts
```

Y nos crea un fichero de este estilo:

```file
bitbucket.org ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAubiN81eDcafrgMeLzaFPsw2kNvEcqTKl/VqLat/MaB33pZy0y3rJZtnqwR2qOOvbwKZYKiEO1O6VqNEBxKvJJelCq0dTXWT5pbO2gDXC6h6QDXCaHo6pOHGPUy+YBaGQRGuSusMEASYiWunYN0vCAI8QaXnWMXNMdFP3jHAJH0eDsoiGnLPBlBp4TNm6rYI74nMzgz3B9IikW4WVK+dc8KZJZWYjAuORU3jc1c/NPskD2ASinf8v3xnfXeukU0sJ5N6m5E8VLjObPEO+mN2t/FZTMZLiFqPWc/ALSqnMnnhwrNi2rbfg/rd/IpL8Le3pSBne8+seeFVBoGqzHM9yXw==
```

#### 2.3 Creación de la imagen

```shell
$ docker build -t springcloudconfigserver .
```

### 3. Configuración del fichero docker-compose.yml

Por defecto se expone el puerto 8888.

```yml
ports:
  - 8888:8888
```

Variables de entorno que hay que poner para conectar a un repositorio Git usando autenticación por usuario y password:

```yml
environment:
  - SPRING_CLOUD_CONFIG_SERVER_GIT_URI=<<dirección https del repositorio git>>
  - SPRING_CLOUD_CONFIG_SERVER_GIT_USERNAME=<<usuario>>
  - SPRING_CLOUD_CONFIG_SERVER_GIT_PASSWORD=<<password>>
```

Por ejemplo:

```yml
environment:
  - SPRING_CLOUD_CONFIG_SERVER_GIT_URI=https://diegopm2000@bitbucket.org/diegopm2000/repoconfigtest.git
  - SPRING_CLOUD_CONFIG_SERVER_GIT_USERNAME=diegopm2000@gmail.com
  - SPRING_CLOUD_CONFIG_SERVER_GIT_PASSWORD=mipassword
```

Variables de entorno que hay que poner para conectar a un repositorio Git usando el par de claves RSA privada/pública:

```yml
environment:
  - SPRING_CLOUD_CONFIG_SERVER_GIT_URI=<<dirección ssh del repositorio git>>
```

Por ejemplo:

```yml
environment:
  - SPRING_CLOUD_CONFIG_SERVER_GIT_URI=git@bitbucket.org:diegopm2000/repoconfigtest.git
```


### 4. Arranque del contenedor

Basta con ejecutar:

```shell
$ docker-compose up
```

### 5. Acceder a los ficheros de configuración

En el repositorio de prueba hemos subido un fichero de propiedades con el nombre siguiente: myapp-dev.properties y que contiene lo siguiente:

```code
ip: 127.0.0.1
password: mypassword
user: myuser
```

Podemos poner en el navegador

```shell
$ curl -X GET http://localhost:8888/myapp-dev.properties
ip: 127.0.0.1
password: mypassword
user: myuser
```

O bien, si queremos la información en formato json:

```shell
$ curl -X GET http://localhost:8888/myapp-dev.json
{"ip":"127.0.0.1","password":"mypassword","user":"myuser"}
```
