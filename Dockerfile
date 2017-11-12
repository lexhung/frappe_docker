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
    wkhtmltopdf python-mysqldb vim sudo

# Install python-pip
RUN wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py
RUN pip install --upgrade setuptools pip

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
RUN chown -R frappe:frappe /app && chmod +x /app/x-*

USER frappe
RUN bench init frappe-bench --skip-bench-mkdir --skip-redis-config-generation

WORKDIR /app/frappe-bench
RUN bench get-app bench_manager https://github.com/frappe/bench_manager
RUN bench get-app erpnext https://github.com/frappe/erpnext
RUN sudo apt-get install -y nginx supervisor
RUN bench setup supervisor --user frappe --yes && \
    cat /app/frappe-bench/config/supervisor.conf

RUN sudo ln -sf /app/cfg/supervisord.conf /etc/supervisor/conf.d/frappe-bench.conf && \
    sudo ln -sf /app/cfg/nginx.conf /etc/nginx/sites-enabled/frappe-sites.conf

ENV REDIS_CACHE=redis://redis-cache:13000
ENV REDIS_QUEUE=redis://redis-queue:11000
ENV REDIS_SOCKETIO=redis://redis-socketio:12000
ENV MARIADB_HOST=mariadb

RUN /app/x-init

ENTRYPOINT ["/app/x-entry"]
CMD ["/app/x-cmd"]