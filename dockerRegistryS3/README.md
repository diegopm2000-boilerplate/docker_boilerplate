# Docker Registry S3 + Frontend

Registro de docker privado con almacenamiento en S3 (minio S3), Frontend específico y autenticación por usuario/password

### 1. Creación de credenciales

Hay que ejecutar previamente este script para crear las credenciales iniciales para poder conectar al registry:

Sustituir <username> y <password> por el usuario y password que queramos

``` shell
$ docker run --rm --entrypoint htpasswd registry:2 -Bbn <username> "<password>" > ~/htpasswd_backup/htpasswd
```

Por ejemplo

``` shell
$ docker run --rm --entrypoint htpasswd registry:2 -Bbn myuser "mypassword" > ~/htpasswd_backup/htpasswd
```

### 2. Creación del bucket

Es necesario crear el bucket antes de subir la primera imagen. El nombre del bucket se configura en el fichero config.yml de la carpeta registry-config, en el apartado relativo a la configuración de s3

En principio le hemos dado el nombre de registry

```shell
bucket: registry
```

### 3. Subir una imagen docker

Es necesario dar un tag con el nombre del repositorio

Por ejemplo, para una imagen que tengamos ya previamente creada, de nombre identityservice.

Podemos introducir el username de forma opcional y no tiene porqué ser con el que nos logamos.

```shell
$ docker tag identityservice localhost:5000/<<username>>/identityservice
```

Hacemos login en el registry:

```shell
$ docker login localhost:5000
```

Se nos pedirá usuario y password, que son los que previamente introdujimos en el paso de creación de credenciales.

Y ya estamos en disposición de subir la imagen:

```shell
$ docker push localhost:5000/<username>/identityservice
```



