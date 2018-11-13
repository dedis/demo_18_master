all: docker-admin docker-conode docker-cothority

docker-admin: mba-admin/Dockerfile
	cd mba-admin; \
	docker build -t mba-admin:1 .

docker-conode: mba-conode/Dockerfile
	cd mba-conode; \
	docker build -t mba-conode:1 --build-arg BUILDFLAG="$(ldflags)" .

docker-cothority: mba-cothority/Dockerfile

admin-run: admin-kill
	docker run --rm -v $$(pwd)/data:/conode_data --name admin mba-admin:1

admin-kill:
	docker rm -f admin || true
