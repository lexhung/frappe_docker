APP_NAME:=frappe
DOCKER_EXEC:=docker exec -it $(APP_NAME) bash -c
SITE_NAME:=bench-manager.local
DOCKER_HOST:=/var/run/docker.sock
DCOMPOSE=docker-compose -H $(DOCKER_HOST)

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
	docker exec -it $(APP_NAME) bash

up:
	$(DCOMPOSE) up -d

logs:
	$(DCOMPOSE) logs -f frappe

build:
	$(DCOMPOSE) build frappe

clean-docker:
	docker rm $$(docker ps -a -q)
	docker rmi $$(docker images | grep "^<none>" | awk "{print $$3}")

destroy-containers:
	$(DCOMPOSE) stop
	$(DCOMPOSE) rm


destroy-data:
	docker volume rm frappedocker_frappe_erpnext_data
	docker volume rm frappedocker_frappe_mariadb_data

destroy: destroy-containers destroy-data

break-in:
	$(DCOMPOSE) exec frappe /bin/bash
