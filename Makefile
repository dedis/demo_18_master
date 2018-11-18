all: clean update-ip build-binaries mba-conode mba-admin mba-cothority

.PHONY: mba-admin mba-conode mba-cothority run-admin kill-admin
IP = 192.168.0.1
VERSION = 4

clean:
	rm -f data/*

update-ip:
	perl -pi -e "s/leaderIP.*/leaderIP: '${IP}:7773'/" www/js/vars.js
	perl -pi -e "s/http:\/\/.*:9001/http:\/\/${IP}:9001/" www/index.html
	@cd mba-admin; \
	perl -pi -e "s-tls://.*:-tls://${IP}:-" *toml co*/*toml

build-binaries:
	@rm -rf bin
	@mkdir bin
	@export GOARCH=amd64; \
	for system in linux windows darwin; do \
	  echo "Building for system $$system"; \
	  export GOOS=$$system; \
		mkdir $$system; \
		for app in ftcosi status byzcoin/bcadmin byzcoin/wallet; do \
		  echo "  Building $$app"; \
		  go build -o bin/$$system/$$(basename $$app) github.com/dedis/cothority/$$app; \
		done; \
		echo "  Building conode"; \
		go build -o $$system/conode -ldflags "-X main.gitTag=1811-mba-${VERSION} -X github.com/dedis/onet.gitTag=1811-mba-${VERSION}" \
		  github.com/dedis/cothority/conode; \
	done

mba-conode:
	@cd mba-conode; \
	for system in linux windows darwin; do \
	  rm -rf conode; mkdir conode; \
		cp setup-then-start.sh ../bin/$$system/conode conode; \
		tar cf conode-$$system.tgz conode; \
	done

mba-admin:
	@cd mba-admin; \
	pkill -f conode; \
	cp ../bin/darwin/{conode,bcadmin} .; \
	rm -f *.cfg; \
	./run_conodes.sh & \
	sleep 5
	pkill -f conode
	@BC=$$( ls mba-admin/bc-*cfg | sed -e "s/.*bc-\(.*\).cfg/\1/" ) ;\
	perl -pi -e "s/byzcoinID.*/byzcoinID: '$$BC',/" www/js/vars.js

mba-cothority:
	@cd mba-cothority; \
	for system in linux windows darwin; do \
	  rm -rf cothority; mkdir cothority; \
		cp ../mba-admin/group.toml cothority; \
		cp ../mba-admin/bc*cfg cothority; \
		cp bc_* msg.txt cothority; \
		cp ../bin/$$system/* cothority; \
		tar cf cothority-$$system.tgz cothority; \
	done

run-admin: kill-admin
	@cd mba-admin; \
	./run_conodes.sh

kill-admin:
	pkill -f conode || true

run-conode:
	@cd mba-conode; \
	./setup_then_start.sh

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
