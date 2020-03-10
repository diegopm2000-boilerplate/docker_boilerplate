# Nodered Dockerizado

### Configuracion inicial de node-red dockerizado

Copiar el fichero de configuracion settings.js de la carpeta /config al directorio /docker-data/node-red/data antes de arrancar el contenedor para que coja los cambios:

```shell
$ cp config/settings.js /docker-data/node-red/data
```

__NOTA__: La carpeta ./volumes/node-red ha de tener permisos adecuados de escritura

En el fichero settings.js se ha configurado:

- user: admin
- password: password
