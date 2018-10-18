# Dockerización de una aplicación de ejemplo que expone un API usando Swagger

La aplicación consiste en un API de colección de películas (MovieCollection) con las funcionalidades básicas de ver listado de películas, introducir nueva película, modificar una película ya existente y borrar una película.

El API se ha creado usando swagger-editor.

La base de datos que se está usando está programada para que funcione en memoria. Al apagar el contenedor se perderán los datos.

Se dockeriza una aplicación de node que expone un servicio http usando swagger-node.

Por defecto la aplicación arranca en el puerto 3000 y se expone en docker-compose.yml al puerto 8080.

El puerto interno por el que arranca la aplicación puede ser definido en la variable de entorno PORT en el docker-compose.yml

### Creación de la imagen

Desde la carpeta Docker, ejecutamos:

```shell
$ docker build -t <your username>/swaggermoviecollection .
```

### Arranque de la imagen

Desde la carpeta raíz ejecutamos:

```shell
$ docker-compose up
```

### Probar la imagen

Desde el navegador web:

http://localhost:8080/movie

Y nos devuelve la lista de películas (inicialmente vacía)

También podemos usar la colección para Postman, dentro de la carpeta del mismo nombre para poder probar rápidamente el API. Basta con importar la colección para empezar a probar.
