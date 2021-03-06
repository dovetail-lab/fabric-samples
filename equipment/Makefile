MAKEFILE_THIS := $(lastword $(MAKEFILE_LIST))
SRC_PATH      := $(patsubst %/,%,$(dir $(abspath $(MAKEFILE_THIS))))
APP_FILE      := equipment.json
APP_NAME      := equipment_cc

LAB_PATH      ?= $(SRC_PATH)/../..
BUILD_PATH    := $(LAB_PATH)/fabric-cli/scripts
FAB_PATH      ?= $(LAB_PATH)/hyperledger/fabric-samples
CC_DEPLOY     := $(FAB_PATH)/chaincode

CLIENT_FILE   := equipment_client.json
CLIENT_NAME   := equipment
CLIENT_OS     ?= darwin

GQL_FILE      := equipment_gql.json

.PHONY: all
all: build deploy

.PHONY: clean
clean:
	rm -Rf $(BUILD_PATH)/work/$(APP_NAME)

.PHONY: build
build: $(APP_FILE) clean
	$(BUILD_PATH)/build.sh cds -f $(APP_FILE) -n $(APP_NAME)

.PHONY: deploy
deploy: $(BUILD_PATH)/work/$(APP_HAME)
	-rm -rf $(CC_DEPLOY)/$(APP_NAME)
	cp -Rf $(BUILD_PATH)/work/$(APP_NAME)/$(APP_NAME) $(CC_DEPLOY)
	cp $(BUILD_PATH)/work/$(APP_NAME)/$(APP_NAME)_linux_amd64 $(CC_DEPLOY)/$(APP_NAME)
	cp $(BUILD_PATH)/work/$(APP_NAME)/$(APP_NAME)_1.0.tar.gz $(CC_DEPLOY)/$(APP_NAME)
	cp fn-cli-init.sh $(FAB_PATH)/test-network/fn-init-equip.sh
	cp fn-cli-test.sh $(FAB_PATH)/test-network/fn-test-equip.sh

.PHONY: deploy-go
deploy-go:
	-mkdir -p $(CC_DEPLOY)/$(APP_NAME)
	cp chaincode.go $(CC_DEPLOY)/$(APP_NAME)
	cp fn-cli-init.sh $(FAB_PATH)/test-network/fn-init-equip.sh
	cp fn-cli-test.sh $(FAB_PATH)/test-network/fn-test-equip.sh

.PHONY: cli-init
cli-init:
	docker exec cli bash -c './fn-init-equip.sh $(APP_NAME)'

.PHONY: cli-test
cli-test:
	docker exec cli bash -c './fn-test-equip.sh $(APP_NAME)'

.PHONY: metadata
metadata:
	fabric-tools metadata -f $(APP_FILE) -m $(SRC_PATH)/contract-metadata/metadata.json -g $(SRC_PATH)/contract-metadata/metadata.gql -o $(SRC_PATH)/contract-metadata/override.json

.PHONY: clean-client
clean-client:
	rm -Rf $(BUILD_PATH)/work/$(CLIENT_NAME)

.PHONY: build-client
build-client: $(CLIENT_FILE) clean-client
	$(BUILD_PATH)/build.sh client -f $(CLIENT_FILE) -n $(CLIENT_NAME) -s $(CLIENT_OS)

.PHONY: run
run:
	FLOGO_APP_PROP_RESOLVERS=env FLOGO_APP_PROPS_ENV=auto PORT=9898 CCNAME=equipment_cc FLOGO_LOG_LEVEL=DEBUG FLOGO_SCHEMA_SUPPORT=true FLOGO_SCHEMA_VALIDATION=false CRYPTO_PATH=$(FAB_PATH)/test-network/organizations $(BUILD_PATH)/work/$(CLIENT_NAME)/$(CLIENT_NAME)_$(CLIENT_OS)_amd64

.PHONY: build-gql
build-gql: $(GQL_FILE) clean-client
	$(BUILD_PATH)/build.sh client -f $(GQL_FILE) -n $(CLIENT_NAME) -s $(CLIENT_OS)

.PHONY: test-network
test-network: $(FAB_PATH)/test-network/network.sh
	cp $(SRC_PATH)/../testdata/docker-compose-cli.yaml $(FAB_PATH)/test-network/docker
	sed -i -e "s/COMPOSE_FILE_BASE=docker\/docker-compose-test-net.yaml.*/COMPOSE_FILE_BASE=\"docker\/docker-compose-test-net.yaml -f docker\/docker-compose-cli.yaml\"/" $(FAB_PATH)/test-network/network.sh

.PHONY: start
start: test-network
	cd $(FAB_PATH)/test-network && ./network.sh up createChannel -s couchdb

.PHONY: shutdown
shutdown:
	cd $(FAB_PATH)/test-network && ./network.sh down
