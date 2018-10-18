# Wordpress dockerizado

Plataforma de blogging Wordpress dockerizada.

### Persistencia

Usa la base de datos mysql como persistencia además de directorios que hay que exponer a volúmenes:

Directorios de wordpress que hay que exponer a volúmenes

```
/var/www/html
/usr/local/etc/php/conf.d/uploads.ini

```

Directorios de mysql que hay que exponer a volúmenes

```
/var/lib/mysql
```
