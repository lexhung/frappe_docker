FROM ubuntu:16.04
MAINTAINER Vishal Seshagiri
MAINTAINER Hung X. Le (lexhung@gmail.com)

USER root
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y iputils-ping \
    git build-essential python-setuptools python-dev libffi-dev libssl-dev \
    redis-tools software-properties-common libxrender1 libxext6 xfonts-75dpi xfonts-base \
    libjpeg8-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev python-tk \
    apt-transport-https libsasl2-dev libldap2-dev libtiff5-dev tcl8.6-dev tk8.6-dev \
    wget curl rlwrap redis-tools nano \
    libmysqlclient-dev mariadb-client mariadb-common \
    wkhtmltopdf python-mysqldb vim sudo nginx supervisor

# Install python-pip
RUN wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py
RUN pip install --upgrade setuptools pip mysql

# Install nodejs
RUN curl https://deb.nodesource.com/node_6.x/pool/main/n/nodejs/nodejs_6.7.0-1nodesource1~xenial1_amd64.deb > node.deb \
 && dpkg -i node.deb \
 && rm node.deb

# User setup
RUN useradd -ms /bin/bash -d /app frappe && usermod -aG sudo frappe

WORKDIR /app
RUN git clone -b develop https://github.com/frappe/bench.git bench-repo
RUN pip install -e bench-repo

# User rules for frappe
RUN printf 'frappe ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/frappe

ADD ./app/ /app/
RUN chown -R frappe:frappe /app && chmod +x /app/x-* && \
    ln -sfn /app/frappe-bench/apps /app/frappe-overlay/apps && \
    ln -sfn /app/frappe-bench/env /app/frappe-overlay/env && \
    ln -sfn /app/frappe-bench/node_modules /app/frappe-overlay/node_modules && \
    ln -sfn /app/frappe-overlay/config /app/frappe-bench/config && \
    ln -sfn /app/frappe-overlay/sites /app/frappe-bench/sites

USER frappe
RUN bench init frappe-bench --skip-bench-mkdir --skip-redis-config-generation

WORKDIR /app/frappe-bench
RUN bench get-app bench_manager https://github.com/frappe/bench_manager
RUN bench get-app erpnext https://github.com/frappe/erpnext
RUN bench setup supervisor --user frappe --yes && \
    cat /app/frappe-bench/config/supervisor.conf

ENV REDIS_CACHE=redis://redis-cache:13000
ENV REDIS_QUEUE=redis://redis-queue:11000
ENV REDIS_SOCKETIO=redis://redis-socketio:12000
ENV MARIADB_HOST=mariadb

RUN /app/x-setup

ENTRYPOINT ["/app/x-entry"]
CMD ["/app/x-cmd"]
