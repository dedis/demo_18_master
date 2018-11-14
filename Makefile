all: mba-admin mba-conode mba-cothority

.PHONY: mba-admin mba-conode mba-cothority run-admin kill-admin

mba-admin: mba-admin/Dockerfile
	cd mba-admin; \
	docker build -t mba-admin:1 .

mba-conode: mba-conode/Dockerfile
	@cd mba-conode; \
	echo "Compiling conode"; \
	GOOS=linux GOARCH=amd64 go build -ldflags "-X main.gitTag=1811-mba-0 -X github.com/dedis/onet.gitTag=1811-mba-0" \
	  github.com/dedis/cothority/conode; \
	docker build -t mba-conode:1 .

mba-cothority: mba-cothority/Dockerfile
	@cd mba-cothority; \
	rm -rf bin; \
	mkdir -p bin; \
	for p in ftcosi status byzcoin/bcadmin; do \
	  echo "Compiling $$p"; \
		GOOS=linux GOARCH=amd64 go build -o bin/$$p github.com/dedis/cothority/$$p; \
	done; \
	docker build -t mba-cothority:1 .

run-admin: kill-admin
	docker run --rm -v $$(pwd)/data:/conode_data -p 7772-7779:7772-7779 --name admin mba-admin:1

kill-admin:
	docker rm -f admin || true

run-conode:
	docker rm -f conode || true
	docker run -ti --rm -v $$(pwd)/data:/conode_data -p 7770-7771:7770-7771 --name conode mba-conode:1

run-cothority:
	docker rm -f cothority || true
	docker run -ti --rm -v $$(pwd)/data:/conode_data --name cothority mba-cothority:1
