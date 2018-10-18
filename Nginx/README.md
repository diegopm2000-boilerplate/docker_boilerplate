# Nginx Dockerizado

Dockerización del servidor de contenido estático Nginx

### Configuración por defecto

En el directorio __default__ se encuentra una configuración por defecto en un docker-compose.yml para arrancar el servidor.

### Configuración custom

En el directorio __Custmonizacion__ se encuentra una configuración customizada

Para probar con un contenido estático distinto del que viene por defecto, hay que hacer lo siguiente:

#### Creamos un fichero Dockerfile con lo siguiente:

```code
FROM nginx

#Copy the application distribution
COPY dist /usr/share/nginx/html
```

Aquí lo que hacemos es copiar nuestra aplicación web que se encuentra en el directorio dist al directorio donde espera nginx encontrarla.

#### Creamos la imagen

```shell
docker build --rm -t diegopm2000/nginxholamundo .
```

#### Arrancamos la imagen

```shell
docker-compose up
```

Para probar la aplicación, basta con poner:

http://localhost:80
