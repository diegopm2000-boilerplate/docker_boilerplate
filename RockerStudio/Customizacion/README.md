# Rocker Studio Dockerizado

Creación de una imagen custom de la herramienta Rocker Studio.

Se basa en la imagen de docker hub:

https://hub.docker.com/r/rocker/rstudio/

### 1. Entrar en la herramienta desde la IP local

http://localhost:8787

- user: rstudio
- password: rstudio

### 2. Directorio de librerías

Rocker Studio usa por defecto el siguiente directorio de librerías:

```shell
/usr/local/lib/R/site-library
```

### 3. Customizacion

Vamos a instalar desde la herramienta web de Rocker Studio las siguientes librerías:

- data.table
- zoo
- forecast
- httr
- jsonlite
- plyr
- lubridate
- ggplot2

Se instalan desde la pestaña Tool y luego se elige __install packages__

Se pueden poner todas de una vez separandolas por __,__ o __espacio__

### 4. Construcción de la imagen customizada

Desde la carpeta de customizacion, ejecutamos

```shell
$ docker build -f Dockerfile --rm -t diegopm2000/rockerstudio .
```

### 5. Arranque de la imagen

```shell
$ docker run -p 8787:8787 -p 8080:8022 <<image_id>>
```

O bien

```shell
$ docker-compose up
```

### 6. Tag de la imagen

```shell
$ docker tag eb740b9bb435 registry.lvtc.gsnet.corp/xis12400/rstudiopoc:1.1
```

### 7. Subir al repositorio de isban de imagenes docker

```shell
docker login -u <<USER>> -p <<PWD>> registry.lvtc.gsnet.corp
```

Y a continuación:

```shell
docker push registry.lvtc.gsnet.corp/xis12400/rstudiopoc:1.0
```
