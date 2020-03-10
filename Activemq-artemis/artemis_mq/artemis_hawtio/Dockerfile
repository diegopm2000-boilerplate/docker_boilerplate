#Base image used for activemq-artemis
FROM vromero/activemq-artemis

MAINTAINER "Diego Perez dperez@tcpsi.es"

#Hawtio console web
ADD hawtio /opt/apache-artemis/web/
#Config (user, roles and hawtio configuration)
ADD config /var/lib/artemis/etc/
