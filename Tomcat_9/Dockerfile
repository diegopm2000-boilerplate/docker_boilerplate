### Set the base image to Tomcat
FROM tomcat:9.0.0.M15-jre8-alpine

### File Author / Maintainer
MAINTAINER "Diego Perez dperez@tcpsi.es"

### Set env memory
ENV JAVA_OPTS="-Xms512m -Xmx2048m"

### Open Ports
EXPOSE 8080

### Copy configuration
ADD conf $CATALINA_HOME/conf/

### Copy deployments (.war inside)
### ADD build/libs $CATALINA_HOME/webapps/
