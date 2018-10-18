### Set the base image to Tomcat
FROM rocker/rstudio

### File Author / Maintainer
MAINTAINER "Diego Perez dperez@tcpsi.es"

### Open Ports
EXPOSE 8787
EXPOSE 8022

### Copy site-library with default libraries and custom (view README.md)
ADD site-library /usr/local/lib/R/site-library/

### Copy src
ADD src /home/rstudio/src/

### Support ssh
RUN apt-get update && apt-get install -y openssh-server
RUN apt-get install sshpass
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

## Copy custom configuration ssh_server
ADD config-ssh /etc/ssh/

ADD arranque /arranque/
RUN chmod +x /arranque/startssh.sh

ENTRYPOINT /arranque/startssh.sh

