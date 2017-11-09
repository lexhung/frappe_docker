#bench Dockerfile

FROM ubuntu:16.04
MAINTAINER Vishal Seshagiri

USER root
RUN apt-get update && apt-get upgrade -y && echo 'UPDATED'
RUN apt-get install -y iputils-ping \
    git build-essential python-setuptools python-dev libffi-dev libssl-dev \
    redis-tools software-properties-common libxrender1 libxext6 xfonts-75dpi xfonts-base \
    libjpeg8-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev python-tk \
    apt-transport-https libsasl2-dev libldap2-dev libtiff5-dev tcl8.6-dev tk8.6-dev \
    wget curl rlwrap redis-tools nano \
    libmysqlclient-dev mariadb-client mariadb-common \
    wkhtmltopdf python-mysqldb vim sudo

# Install python-pip
RUN wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py
RUN pip install --upgrade setuptools pip

# Install nodejs
RUN curl https://deb.nodesource.com/node_6.x/pool/main/n/nodejs/nodejs_6.7.0-1nodesource1~xenial1_amd64.deb > node.deb \
 && dpkg -i node.deb \
 && rm node.deb
 
# User setup
RUN useradd -ms /bin/bash frappe && usermod -aG sudo frappe
RUN printf '# User rules for frappe\nfrappe ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/frappe

WORKDIR /home/frappe
RUN git clone -b develop https://github.com/frappe/bench.git bench-repo
RUN pip install -e bench-repo

ADD frappe-bench /home/frappe/
RUN chown -R frappe:frappe /home/frappe/*

USER frappe
RUN bench init frappe-bench --skip-bench-mkdir --skip-redis-config-generation

WORKDIR /home/frappe/frappe-bench
RUN bench get-app bench_manager https://github.com/frappe/bench_manager
RUN bench get-app erpnext https://github.com/frappe/erpnext
RUN bench set-mariadb-host mariadb


