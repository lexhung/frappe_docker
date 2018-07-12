APP_NAME:=frappe
SITE_NAME:=bench-manager.local
DOCKER_HOST_PARAM:=
COMPOSE=docker-compose $(DOCKER_HOST_PARAM)
DOCKER_EXEC:=$(DOCKER) exec -it $(APP_NAME) bash -c
DOCKER=docker $(DOCKER_HOST_PARAM)
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
	$(COMPOSE) run frappe /bin/bash

bash:
	$(DOCKER) exec -it $(APP_NAME) bash

up:
	$(COMPOSE) up -d

stop:
	$(COMPOSE) stop

logs:
	$(COMPOSE) logs -f frappe

build:
	$(DOCKER) build -t $(NAMESPACE)/frappe ./frappe
	$(DOCKER) build -t $(NAMESPACE)/mariadb ./mariadb

clean-docker:
	$(DOCKER) rm $$($(DOCKER) ps -a -q)
	$(DOCKER) rmi $$($(DOCKER) images | grep "^<none>" | awk "{print $$3}")

destroy-containers:
	$(COMPOSE) stop
	$(COMPOSE) rm


destroy-data:
	$(DOCKER) volume rm frappe_erpnext_data
	$(DOCKER) volume rm frappe_mariadb_data

destroy: destroy-containers destroy-data

break-in:
	$(COMPOSE) exec frappe /bin/bash
