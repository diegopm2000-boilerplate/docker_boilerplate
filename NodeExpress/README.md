# Dockerización de una aplicación Hola Mundo usando Node y la librería Express

Se dockeriza una aplicación de node que expone un servicio http usando express.
El servicio simplemente devuelve por http el mensaje de texto:

Hello world Node Express!!!

### Creación de la imagen

Desde la carpeta Docker, ejecutamos:

```shell
$ docker build -t <your username>/node-web-app .
```

### Arranque de la imagen

Desde la carpeta raíz ejecutamos:

```shell
$ docker-compose up
```

Se expone el puerto 8080

### Probar la imagen

Desde el navegador web:

http://localhost:8080

Y nos devuelve:

Hello world Node Express!!!

O bien usando curl:

```shell
$ curl -X GET http://localhost:8080
Hello world Node Express!!!
```
