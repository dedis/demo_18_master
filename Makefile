all: clean mba-conode mba-admin mba-cothority

IP = 192.168.0.42
VERSION = 3
DOCKER_PREFIX = dedis/mba-

.PHONY: mba-admin mba-conode mba-cothority run-admin kill-admin

clean:
	rm -f data/*

update-ip:
	perl -pi -e "s/leaderIP.*/leaderIP: '${IP}:7773'/" www/js/vars.js
	perl -pi -e "s/http:\/\/.*:9001/http:\/\/${IP}:9001/" www/index.html

build-binaries:
	rm -rf bin
	mkdir bin
	export GOARCH=amd64; \
	for system in linux windows darwin; do \
	  export GOOS=$$system; \
		for app in ftcosi status byzcoin/bcadmin byzcoin/wallet; do \
		  go build -o $$(basename $$app) $$app; \
		done; \
	done

mba-admin: mba-admin/Dockerfile update-ip

fetch_cothority:
	go get github.com/dedis/cothority
	cd $$( go env GOPATH )/src/github.com/dedis/cothority
	git checkout mba_1811
	go get ./...

mba-admin: mba-admin/Dockerfile
	@cd mba-admin; \
	perl -pi -e "s-tls://.*:-tls://${IP}:-" *toml co*/*toml; \
	echo "Building bcadmin"; \
	GOOS=linux GOARCH=amd64 go build -o bcadmin github.com/dedis/cothority/byzcoin/bcadmin; \
	docker build -t mba-admin:${VERSION} .
	docker tag mba-admin:${VERSION} ${DOCKER_PREFIX}admin:latest
	make run-admin &
	sleep 10
	make kill-admin
	BC=$$( ls data/bc-* | sed -e "s/.*bc-\(.*\).cfg/\1/" ) ;\
	perl -pi -e "s/byzcoinID.*/byzcoinID: '$$BC',/" www/js/vars.js

mba-conode: mba-conode/Dockerfile
	@cd mba-conode; \
	echo "Compiling conode"; \
	GOOS=linux GOARCH=amd64 go build -ldflags "-X main.gitTag=1811-mba-${VERSION} -X github.com/dedis/onet.gitTag=1811-mba-${VERSION}" \
	  github.com/dedis/cothority/conode; \
	docker build -t mba-conode:${VERSION} .
	docker tag mba-conode:${VERSION} ${DOCKER_PREFIX}conode:latest

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
	docker tag mba-cothority:${VERSION} ${DOCKER_PREFIX}cothority:latest

docker-push:
	docker push ${DOCKER_PREFIX}conode:latest
	docker push ${DOCKER_PREFIX}cothority:latest

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
	if [ ! -d student_18_explorer ]; then \
	  git clone github.com/dedis/student_18_explorer ;\
		cd student_18_explorer; \
		make build; \
		cd .. ;\
	fi ;\
	if [ ! -d etherpad-lite ]; then \
  	git clone https://github.com/ether/etherpad-lite.git; \
	fi ;\
	( pkill -f etherpad; cd etherpad-lite; bin/run.sh & ); \
	python -m SimpleHTTPServer 8000
