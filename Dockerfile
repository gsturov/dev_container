FROM ubuntu:20.04

ENV TZ=America/Toronto
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

## Install additional packes
RUN apt-get update && \
    apt-get -y install curl openssh-server dnsutils sudo git mc python3-pip && \
    apt-get clean

## Install go or other dependencies that you need for development
ARG goarchive=go1.15.3.linux-amd64.tar.gz
RUN curl -O https://dl.google.com/go/$goarchive && tar -C /usr/local -xzf $goarchive && rm $goarchive
RUN echo export PATH=$PATH:/usr/local/go/bin >> /etc/profile

## Create development user
ARG user=gleb
RUN useradd -ms /bin/bash $user
RUN mkdir /home/$user/.ssh
RUN mkdir /home/$user/bin

ADD sshd_starter.py /home/$user/bin/sshd_starter.py
ADD --chown=$user:$user authorized_keys home/$user/.ssh/authorized_keys

RUN echo "gleb ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/gleb

## Configure openssh server
RUN echo "\n\
PasswordAuthentication no \n\
PermitRootLogin no \n\
MaxAuthTries 3 \n\
LoginGraceTime 10 \n\
PermitEmptyPasswords no \n\
ChallengeResponseAuthentication no \n\
KerberosAuthentication no \n\
GSSAPIAuthentication no \n\
X11Forwarding no \n\
HostKey /etc/ssh/ssh_host_rsa_key \n\
" >> /etc/ssh/sshd_config


RUN mkdir /run/sshd
RUN cd /etc/ssh && ssh-keygen -A

USER root

# CMD service ssh restart && sleep infinity
CMD /home/gleb/bin/sshd_starter.py && sleep infinity

EXPOSE 22 3200