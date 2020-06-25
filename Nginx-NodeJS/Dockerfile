FROM nginx

### File Author / Maintainer
MAINTAINER "Diego Perez Molinero"

# Install Node
RUN apt update && apt -y install curl gnupg
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt -y install nodejs
# Development tools used to build native addons
RUN apt -y install gcc g++ make

