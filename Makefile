DOCKER_EXEC:=docker exec -it frappe bash -c
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
