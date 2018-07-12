FROM ubuntu:16.04
MAINTAINER Vishal Seshagiri
MAINTAINER Hung X. Le (lexhung@gmail.com)

ENV URL_NODEJS_DEB=https://deb.nodesource.com/node_6.x/pool/main/n/nodejs/nodejs_6.11.2-1nodesource1~xenial1_amd64.deb
ENV URL_WKHTMLTOPDF_DEB=https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.xenial_amd64.deb
ENV BRANCH_ERPNEXT=master
ENV BRANCH_BENCH_MANAGER=develop
ENV BRANCH_FRAPPE=master
ENV BRANCH_BENCH=master

USER root
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y iputils-ping \
    git build-essential python-setuptools python-dev libffi-dev libssl-dev \
    redis-tools software-properties-common libxrender1 libxext6 xfonts-75dpi xfonts-base \
    libjpeg8-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev python-tk \
    apt-transport-https libsasl2-dev libldap2-dev libtiff5-dev tcl8.6-dev tk8.6-dev \
    wget curl rlwrap redis-tools nano \
    libmysqlclient-dev mariadb-client mariadb-common \
    wkhtmltopdf python-mysqldb vim sudo nginx supervisor redis-server

# Install python-pip
RUN wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py
RUN pip install --upgrade setuptools pip mysql

# Install nodejs
RUN curl -L $URL_NODEJS_DEB > node.deb
RUN curl -L $URL_WKHTMLTOPDF_DEB > wkhtmltopdf.deb
RUN dpkg -i *.deb && apt-get install -f && apt-get autoremove -y && rm *.deb

# User setup
RUN useradd -ms /bin/bash -d /opt/frappe-bench frappe && usermod -aG sudo frappe

WORKDIR /app
RUN git clone -b $BRANCH_BENCH https://github.com/frappe/bench.git bench-repo
RUN pip install -e bench-repo

# User rules for frappe
RUN printf 'frappe ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/frappe

ENV REDIS_CACHE=redis://localhost:13000
ENV REDIS_QUEUE=redis://localhost:11000
ENV REDIS_SOCKETIO=redis://localhost:12000
ENV MARIADB_HOST=mariadb

USER frappe
ADD ./app/frappe-bench/ /opt/frappe-bench/
RUN sudo chown -R frappe:frappe /opt/frappe-bench && \
    cd /opt && bench init --frappe-branch=$BRANCH_FRAPPE --ignore-exist --skip-redis-config-generation frappe-bench
RUN cd /opt/frappe-bench && bench get-app --branch $BRANCH_BENCH_MANAGER bench_manager https://github.com/frappe/bench_manager
RUN cd /opt/frappe-bench && bench get-app --branch $BRANCH_ERPNEXT erpnext https://github.com/frappe/erpnext

ADD ./app/ /app/
RUN sudo chown -R frappe:frappe /app && chmod +x /app/bin/x-* &&\
 sudo ln -sf /app/config/nginx.conf /etc/nginx/sites-enabled/default &&\
 sudo ln -sf /app/config/supervisord-application.conf /etc/supervisor/conf.d/application.conf &&\
 sudo ln -sf /app/config/supervisord-service.conf /etc/supervisor/conf.d/service.conf &&\
 sudo mv /opt/frappe-bench/sites /opt/frappe-bench/sites.local  &&\
 sudo mkdir /opt/frappe-bench/sites

VOLUME /opt/frappe-bench/sites

ENTRYPOINT ["/app/bin/x-entry"]
CMD ["/app/bin/x-cmd"]
