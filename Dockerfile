FROM ubuntu:20.04

ENV TZ=America/Toronto
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

## Install additional packes
RUN apt-get update && \
    apt-get -y install curl openssh-server dnsutils sudo git mc python3-pip screen && \
    apt-get clean

## Install go or other dependencies that you need for development
ARG goarchive=go1.15.3.linux-amd64.tar.gz
RUN curl -O https://dl.google.com/go/$goarchive && tar -C /usr/local -xzf $goarchive && rm $goarchive
RUN echo export PATH=$PATH:/usr/local/go/bin >> /etc/profile

RUN curl -sL https://deb.nodesource.com/setup_14.x | sudo bash -
RUN apt -y install nodejs
RUN apt -y install rsync

RUN mkdir /app
RUN chmod 777 /app

RUN echo '\n\
[dev] \n\
path = /app \n\
comment = "app" \n\
read only = false \n\
use chroot = false \n\
' >> /etc/rsyncd.conf

RUN echo '\n\
cd /app \n\
while [ 1 -le 2 ] \n\
do \n\
    sleep 1 \n\
    if test -f "/app/notices"; then \n\
        sleep 2 \n\
        echo "restarting node" \n\
        rm /app/notices \n\
        pkill node \n\
        node --inspect build/app.js & \n\
    fi \n\
done \n\
' >> /usr/local/bin/restart
RUN chmod a+x /usr/local/bin/restart

RUN echo '/usr/local/bin/restart &' >> /usr/local/bin/init_restart
RUN chmod a+x /usr/local/bin/init_restart

CMD /usr/local/bin/init_restart && rsync --daemon && sleep infinity

EXPOSE 873 9229 3000
