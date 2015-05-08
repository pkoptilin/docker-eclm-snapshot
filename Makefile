TAG=latest
_DOCKER_HOST := tcp://$(shell boot2docker ip):2376
_DOCKER_CERT_PATH := $(shell echo ~)/.boot2docker/certs/boot2docker-vm
_DOCKER_TLS_VERIFY := 1
CID := $(shell export DOCKER_TLS_VERIFY=$(_DOCKER_TLS_VERIFY);export DOCKER_HOST=$(_DOCKER_HOST);export DOCKER_CERT_PATH=$(_DOCKER_CERT_PATH);docker ps -l -q)
#OPT := -H $(_DOCKER_HOST) --tlsverify --tlscacert="$(_DOCKER_CERT_PATH)/ca.pem" --tlscert="$(_DOCKER_CERT_PATH)/cert.pem" --tlskey="$(_DOCKER_CERT_PATH)/key.pem"
OPT :=
DOCKERC := docker $(OPT)
CNAME :=
CMD :=
INAME := eclm/snapshot
LINK := --link oracle:oracle
PORTS := -p 8080:8080 -p 9990:9990 -p 8787:8787

init:
	@boot2docker shellinit
build:
	$(DOCKERC) build --tag=$(INAME) .
run:
	$(DOCKERC) run -d $(CNAME) $(PORTS) $(LINK) $(INAME):$(TAG)
bash:
	$(DOCKERC) run -ti $(PORTS) $(LINK) $(INAME):$(TAG) /bin/bash
commit:
	$(DOCKERC) commit $(CID) $(INAME):$(TAG)
stop:
	$(DOCKERC) stop $(CID)
show:
	@$(DOCKERC) ps; $(DOCKERC) logs $(CID)
log: 
	@$(DOCKERC) logs -f $(CID)
clean:
	$(DOCKERC) stop $(INAME):$(TAG); docker rm $(CID)
ps:
	$(DOCKERC) ps
all:clean,build,run
help:
	@echo docker helper
	@echo Commands:
	@echo "     build"
	@echo "     run"
	@echo "     bash"
	@echo "     commit TAG=tag"
	@echo "     stop"
	@echo "     clean"
	@echo "     ps"
	@echo "     help"
	@echo -----------------------------------------
	@echo wildfly admin console: user:admin pass: Admin#70365
	@echo when deploy war, runtime name must be 'eclm.war'
	@echo -----------------------------------------



run-ext:
	$(DOCKERC) run -d $(PORTS) --name eclm-$(TAG) $(LINK) $(INAME):$(TAG) $(CMD)

debug:
	$(DOCKERC) run -d $(PORTS) $(LINK) $(INAME) /opt/jboss/wildfly/bin/standalone.sh --debug 8787 --server-config standalone-full-ha.xml -b 0.0.0.0 -bmanagement 0.0.0.0

