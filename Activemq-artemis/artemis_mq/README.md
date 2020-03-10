# Artemis Active Mq Dockerizado

Se construye una imagen del broker de mensajería Artemis Active Mq.

Hemos partido de la imagen de docker hub siguiente:

vromero/activemq-artemis

### Hawtio añadido como visor en browser del broker de colas

Y hemos añadido __Hawtio__ como consola web de monitorización.

Se ha modificado en el fichero de configuración artemis.profile la línea de JAVA_ARGS añadiendo:

```code
-Dhawtio.realm=activemq -Dhawtio.role=admin -Dhawtio.rolePrincipalClasses=org.apache.activemq.artemis.spi.core.security.jaas.RolePrincipal
```

Se modifica el fichero __artemis-roles.properties__ añadiendo el rol de __admin__, que es el que usa Hawtio al que hemos añadido el usuario artemis.

Se modifica el fichero __artemis-users.properties__ donde hemos modificado la clave de artemis por: password

Para acceder a Hawtio

http://localhost:8161/Hawtio

user: artemis

password: password

### Uso de JConsole para visualizar el estado del broker de colas

Se ha modificado en el fichero de configuración artemis.profile la línea de JAVA_ARGS añadiendo:

```code
-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.port=1099 -Dcom.sun.management.jmxremote.rmi.port=1098 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false
```

Hemos abierto el puerto 1099 en el docker-compose para poder entrar con jconsole:

Escribimos en un terminal, con Java instalado correctamente:

```shell
$ jconsole
```

Como parámetros de acceso hay que poner:

localhost:1099 y pulsamos en el botón de Aceptar (no hace falta poner usuario ni password)
