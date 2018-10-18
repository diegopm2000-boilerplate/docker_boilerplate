# Tomcat 8 Dockerizado

Tomcat 8 dockerizado que se crea a partir de la imagen oficial y que ofrece acceso a la consola de administración.

Para poder tener acceso a la consola de administración es necesario introducir el fichero tomcat-users.xml, lo que se hace usando un dockerfile especifico.

### Construcción de la imagen

ara construir la imagen, se usa gradle, y hay que ejecutar:

```shell
$ buildImageDocker
```
### Acceso a la consola de administración:

http://localhost:8080

- user: admin
- password: mysecretpassword
