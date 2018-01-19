APP_NAME:=frappe
SITE_NAME:=bench-manager.local
DHOST_PARAM:=--host localhost:2379
DCOMPOSE=docker-compose $(DHOST_PARAM)
DOCKER_EXEC:=$(DOCKER) exec -it $(APP_NAME) bash -c
DOCKER=docker $(DHOST_PARAM)
NAMESPACE:=fiisoft

create-site:
	$(DOCKER_EXEC) "bench new-site $(SITE_NAME)"

create-site-force:
	$(DOCKER_EXEC) "bench new-site $(SITE_NAME) --force"

install-app:
	$(DOCKER_EXEC) "./env/bin/pip install -U mysql"
	$(DOCKER_EXEC) "bench --site $(SITE_NAME) install-app bench_manager"
	$(DOCKER_EXEC) "bench --site $(SITE_NAME) install-app erpnext"

init-force: create-site-force install-app

init: create-site install-app

start:
	$(DOCKER_EXEC) "bench start"

run:
	$(DCOMPOSE) run frappe /bin/bash

bash:
	$(DOCKER) exec -it $(APP_NAME) bash

up:
	$(DCOMPOSE) up -d

stop:
	$(DCOMPOSE) stop

logs:
	$(DCOMPOSE) logs -f frappe

build:
	$(DOCKER) build -t $(NAMESPACE)/frappe ./frappe
	$(DOCKER) build -t $(NAMESPACE)/mariadb ./mariadb

clean-docker:
	$(DOCKER) rm $$($(DOCKER) ps -a -q)
	$(DOCKER) rmi $$($(DOCKER) images | grep "^<none>" | awk "{print $$3}")

destroy-containers:
	$(DCOMPOSE) stop
	$(DCOMPOSE) rm


destroy-data:
	$(DOCKER) volume rm frappe_erpnext_data
	$(DOCKER) volume rm frappe_mariadb_data

destroy: destroy-containers destroy-data

break-in:
	$(DCOMPOSE) exec frappe /bin/bash
