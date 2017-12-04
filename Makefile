APP_NAME:=frappe
DOCKER_EXEC:=docker exec -it $(APP_NAME) bash -c
SITE_NAME:=bench-manager.local

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

bash:
	docker exec -it $(APP_NAME) bash

up:
	docker-compose up -d

build:
	docker-compose build frappe

clean-docker:
	docker rm $$(docker ps -a -q)
	docker rmi $$(docker images | grep "^<none>" | awk "{print $$3}")
