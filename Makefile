all: clean mba-conode mba-admin mba-cothority

.PHONY: mba-admin mba-conode mba-cothority run-admin kill-admin
IP = 192.168.0.42
VERSION=3

clean:
	rm -f data/*

mba-admin: mba-admin/Dockerfile
	@cd mba-admin; \
	perl -pi -e "s-tls://.*:-tls://${IP}:-" *toml co*/*toml; \
	echo "Building bcadmin"; \
	GOOS=linux GOARCH=amd64 go build -o bcadmin github.com/dedis/cothority/byzcoin/bcadmin; \
	docker build -t mba-admin:${VERSION} .
	docker tag mba-admin:${VERSION} dedis/mba-admin:latest
	make run-admin &
	sleep 10
	make kill-admin

mba-conode: mba-conode/Dockerfile
	@cd mba-conode; \
	echo "Compiling conode"; \
	GOOS=linux GOARCH=amd64 go build -ldflags "-X main.gitTag=1811-mba-0 -X github.com/dedis/onet.gitTag=1811-mba-0" \
	  github.com/dedis/cothority/conode; \
	docker build -t mba-conode:${VERSION} .
	docker tag mba-conode:${VERSION} dedis/mba-conode:latest

mba-cothority: mba-cothority/Dockerfile
	@cd mba-cothority; \
	rm -rf bin; \
	mkdir -p bin; \
	for p in ftcosi status byzcoin/bcadmin byzcoin/wallet; do \
	  echo "Compiling $$p"; \
		GOOS=linux GOARCH=amd64 go build -o bin/$$p github.com/dedis/cothority/$$p; \
	done; \
	cp ../mba-admin/public.toml .; \
	rm bc*cfg; \
	cp ../data/bc*cfg .; \
	docker build -t mba-cothority:${VERSION} .
	docker tag mba-cothority:${VERSION} dedis/mba-cothority:latest

docker-push:
	docker push dedis/mba-conode:latest
	docker push dedis/mba-cothority:latest

run-admin: kill-admin
	docker run --rm -v $$(pwd)/data:/conode_data -p 7772-7781:7772-7781 --name admin mba-admin:${VERSION}

kill-admin:
	docker rm -f admin || true

run-conode:
	docker rm -f conode || true
	docker run -ti --rm -v $$(pwd)/data:/conode_data -p 7770-7771:7770-7771 --name conode mba-conode:${VERSION}

run-cothority:
	docker rm -f cothority || true
	docker run -ti --rm -v $$(pwd)/data:/conode_data --name cothority mba-cothority:${VERSION}

run-www:
	cd www; \
	npm run-script build; \
	python -m SimpleHTTPServer 8000
