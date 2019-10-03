# Nginx con certificado autofirmado

### 1. Creamos el certificado

```
$ sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./certificates/nginx-selfsigned.key -out ./certificates/nginx-selfsigned.crt
```

### 2. Configuración de nginx para que arranque con los certificados

En el fichero nginx.conf hemos añadido al texto que viene por defecto:

```
listen       443 ssl;
#listen       80;

ssl_certificate     certificates/nginx-selfsigned.crt;
ssl_certificate_key certificates/nginx-selfsigned.key;
ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
ssl_ciphers         HIGH:!aNULL:!MD5;
```

Básicamente hemos comenado el puerto 80, y añadido las otras cuatro líneas.

### 3. docker-compose.yml

```
version: '3.1'

services:

  holamundocert-nginx:
    image: nginx:latest
    ports:
      - 0.0.0.0:443:443
    volumes:
        - ./docker-conf:/etc/nginx/conf.d
        - ./dist:/usr/share/nginx/html
        - ./certificates:/etc/nginx/certificates
    networks:
      - docker-network

networks:
  docker-network:
    driver: bridge
```

### 4. Volumenes que hemos usado

docker-conf: configuración de nginx
dist: aquí ponemos la aplicación html
certificates: aquí tenemos los certificados

### 5. Como probarlo

Escribimos en el navegador:

https://localhost

Y debería aparecer la página index.html

