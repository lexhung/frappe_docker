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
    wkhtmltopdf python-mysqldb vim sudo nginx supervisor mariadb-server redis-server

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

ENV REDIS_CACHE=redis://localhost:13000
ENV REDIS_QUEUE=redis://localhost:11000
ENV REDIS_SOCKETIO=redis://localhost:12000
ENV MARIADB_HOST=mariadb

USER frappe
ADD ./app/frappe-bench/ /app/frappe-bench/
RUN sudo chown -R frappe:frappe /app/frappe-bench &&\
    cd /app &&\
    bench init frappe-bench --skip-bench-mkdir --skip-redis-config-generation
RUN cd /app/frappe-bench &&\
    bench get-app bench_manager https://github.com/frappe/bench_manager &&\
    bench get-app erpnext https://github.com/frappe/erpnext

ADD ./app/config/ /app/config/
ADD ./app/bin/ /app/bin/
RUN sudo chown -R frappe:frappe /app && chmod +x /app/bin/x-* &&\
 sudo ln -sf /app/config/nginx.conf /etc/nginx/sites-enabled/default &&\
 sudo ln -sf /app/config/supervisord.conf /etc/supervisor/conf.d/frappe-bench.conf

VOLUME /app/logs
VOLUME /app/frappe-bench/sites

ENTRYPOINT ["/app/bin/x-entry"]
CMD ["/app/bin/x-cmd"]
