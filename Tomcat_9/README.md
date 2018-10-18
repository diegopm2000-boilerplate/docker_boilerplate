# Tomcat 9 Dockerizado

Tomcat 9 dockerizado que se crea a partir de la imagen oficial y que ofrece acceso a la consola de administración.

Para poder tener acceso a la consola de administración es necesario introducir el fichero tomcat-users.xml, lo que se hace usando un dockerfile especifico.

También se ha modificado convenientemente para poder entrar en la consola de administración desde cualquier máquina distinta a donde arranca el tomcat (desde el host poder acceder al contenedor docker). Se han añadido ficheros manager.xml y host-manager.xml que deshabilitan el modo de funcionamiento por defecto de estas aplicaciones.

NOTA: Para acceder dentro del contenedor hay que poner /bin/sh en lugar de /bin/bash

### Construcción de la imagen

ara construir la imagen, se usa gradle, y hay que ejecutar:

```shell
$ buildImageDocker
```
### Acceso a la consola de administración:

http://localhost:8080

- user: admin
- password: mysecretpassword
