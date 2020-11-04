MAKEFILE_THIS := $(lastword $(MAKEFILE_LIST))
SRC_PATH      := $(patsubst %/,%,$(dir $(abspath $(MAKEFILE_THIS))))
APP_FILE      := marble.json
APP_NAME      := marble_cc

LAB_PATH      ?= $(SRC_PATH)/../..
BUILD_PATH    := $(LAB_PATH)/fabric-cli/scripts
FAB_PATH      ?= $(LAB_PATH)/hyperledger/fabric-samples
CC_DEPLOY     := $(FAB_PATH)/chaincode

CLIENT_FILE   := marble-client.json
CLIENT_NAME   := marble-client
CLIENT_OS     ?= darwin

FE_CLIENT_FILE := marble-fe.json

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
	cp fn-cli-init.sh $(FAB_PATH)/test-network/fn-init-marble.sh
	cp fn-cli-test.sh $(FAB_PATH)/test-network/fn-test-marble.sh

.PHONY: cli-init
cli-init:
	docker exec cli bash -c './fn-init-marble.sh'

.PHONY: cli-test
cli-test:
	docker exec cli bash -c './fn-test-marble.sh'

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
	FLOGO_APP_PROP_RESOLVERS=env FLOGO_APP_PROPS_ENV=auto PORT=8989 FLOGO_LOG_LEVEL=DEBUG FLOGO_SCHEMA_SUPPORT=true FLOGO_SCHEMA_VALIDATION=false CRYPTO_PATH=$(FAB_PATH)/test-network/organizations $(BUILD_PATH)/work/$(CLIENT_NAME)/$(CLIENT_NAME)_$(CLIENT_OS)_amd64

.PHONY: build-fe-client
build-fe-client: $(FE_CLIENT_FILE) clean-client
	$(BUILD_PATH)/build.sh client -f $(FE_CLIENT_FILE) -n $(CLIENT_NAME) -s $(CLIENT_OS)

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
