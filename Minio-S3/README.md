# Minio S3 dockerizado

Almacenamiento S3 Minio dockerizado

### Para entrar en el contenedor:

docker exec -ti <container_id> /bin/sh

En lugar de

docker exec -ti <container_id> /bin/bash

### Repositorio de GitHub:

https://github.com/minio/minio

### Repositorio de DockerHub:

https://hub.docker.com/r/minio/minio/

### Directorio que hay que exponer a volumen para persistencia:

```shell
/export
```
