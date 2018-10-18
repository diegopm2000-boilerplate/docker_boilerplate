# Docker Golang Runner

Contenedor de Golang que inyecta una aplicación de Go y al arrancar la ejecuta.

### Creación de la imagen docker usando el dockerfile

```shell
$ docker build -t diegopm2000/golang .
```

Lo que hace es partiendo de la imagen oficial de Golang de docker hub, copia el código del directorio /app y a continuación lo ejecuta (se compila al vuelo durante la ejecución, sin generar un fichero del compilado)

### Ejecución del contenedor para que ejecute el programa

```shell
$ docker run diegopm2000/golang
```
