FROM alpine-java:base

MAINTAINER Diego Perez Molinero

RUN mkdir -p /root/.ssh
RUN chmod 700 /root/.ssh
ADD ssh_config /root/.ssh/
RUN chmod 600 /root/.ssh/known_hosts

COPY files/spring-cloud-config-server-1.3.0.RELEASE.jar /opt/spring-cloud/lib/spring-cloud-config-server.jar

ENTRYPOINT ["/usr/bin/java"]
CMD ["-jar", "/opt/spring-cloud/lib/spring-cloud-config-server.jar"]

EXPOSE 8888
