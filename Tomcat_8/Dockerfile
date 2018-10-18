### Set the base image to Tomcat
FROM tomcat

### File Author / Maintainer
MAINTAINER "Diego Perez dperez@tcpsi.es"

### Set env memory
ENV JAVA_OPTS="-Xms512m -Xmx2048m"

### Open Ports
EXPOSE 8080

### Copy configuration
ADD conf/tomcat-users.xml $CATALINA_HOME/conf/tomcat-users.xml

### Copy deployments (.war inside)
### ADD build/libs $CATALINA_HOME/webapps/
