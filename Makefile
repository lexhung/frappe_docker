DOCKER_EXEC:=docker exec -it frappe bash -c
SITE_NAME:=bench-manager.local
	
init-site:
	$(DOCKER_EXEC) "bench new-site $(SITE_NAME) --force"
	$(DOCKER_EXEC) "bench --site $(SITE_NAME) install-app bench_manager"
	$(DOCKER_EXEC) "bench --site $(SITE_NAME) install-app erpnext"
