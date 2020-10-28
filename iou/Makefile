MAKEFILE_THIS := $(lastword $(MAKEFILE_LIST))
SRC_PATH      := $(patsubst %/,%,$(dir $(abspath $(MAKEFILE_THIS))))
APP_FILE      := iou.json
APP_NAME      := iou_cc

LAB_PATH      ?= $(SRC_PATH)/../..
BUILD_PATH    := $(LAB_PATH)/fabric-cli/scripts
FAB_PATH      ?= $(LAB_PATH)/hyperledger/fabric-samples
CC_DEPLOY     := $(FAB_PATH)/chaincode

CLIENT_FILE   := iou_client.json
CLIENT_NAME   := iou
CLIENT_OS     ?= darwin

.PHONY: all
all: build deploy

.PHONY: clean
clean:
	rm -Rf $(BUILD_PATH)/work/$(APP_NAME)

.PHONY: build
build: $(APP_FILE) clean
	$(BUILD_PATH)/build.sh cds -f $(APP_FILE) -n $(APP_NAME)

.PHONY: deploy
deploy: $(BUILD_PATH)/work/$(APP_NAME)
	-rm -rf $(CC_DEPLOY)/$(APP_NAME)
	cp -Rf $(BUILD_PATH)/work/$(APP_NAME)/$(APP_NAME) $(CC_DEPLOY)
	cp $(BUILD_PATH)/work/$(APP_NAME)/$(APP_NAME)_linux_amd64 $(CC_DEPLOY)/$(APP_NAME)
	cp $(BUILD_PATH)/work/$(APP_NAME)/$(APP_NAME)_1.0.cds $(CC_DEPLOY)/$(APP_NAME)
	cp collections_config.json $(CC_DEPLOY)/$(APP_NAME)
	cp fn-cli-init.sh $(FAB_PATH)/first-network/scripts/fn-init-iou.sh

.PHONY: start-fn
start-fn:
	./start-fn.sh $(FAB_PATH)
	./gen-user.sh $(FAB_PATH) EURBankAdmin 1
	./gen-user.sh $(FAB_PATH) Alice 1
	./gen-user.sh $(FAB_PATH) Bob 1
	./gen-user.sh $(FAB_PATH) USDBankAdmin 2
	./gen-user.sh $(FAB_PATH) Carol 2
	./gen-user.sh $(FAB_PATH) David 2

.PHONY: cli-init
cli-init:
	docker exec cli bash -c 'cd scripts; ./fn-init-iou.sh'

.PHONY: metadata
metadata:
	mkdir -p $(SRC_PATH)/contract-metadata
	fabric-tools metadata -f $(APP_FILE) -m $(SRC_PATH)/contract-metadata/metadata.json -g $(SRC_PATH)/contract-metadata/metadata.gql -o $(SRC_PATH)/contract-metadata/override.json
	cd $(SRC_PATH)/contract-metadata && \
	sed -i -e "s/redeem(/redeem(owner: String, /" ./metadata.gql && \
	sed -i -e "s/exchange(/exchange(owner: String, /" ./metadata.gql && \
	sed -i -e "s/transfer(/transfer(owner: String, /" ./metadata.gql && \
	sed -i -e "s/send(/send(receiver: String, /" ./metadata.gql && \
	rm metadata.gql-e

.PHONY: clean-client
clean-client:
	rm -Rf $(BUILD_PATH)/work/$(CLIENT_NAME)

.PHONY: build-client
build-client: $(CLIENT_FILE) clean-client
	$(BUILD_PATH)/build.sh client -f $(CLIENT_FILE) -n $(CLIENT_NAME) -s $(CLIENT_OS)

.PHONY: run
run:
	FLOGO_APP_PROP_RESOLVERS=env FLOGO_APP_PROPS_ENV=auto PORT=8989 FLOGO_LOG_LEVEL=DEBUG FLOGO_SCHEMA_SUPPORT=true FLOGO_SCHEMA_VALIDATION=false CRYPTO_PATH=$(FAB_PATH)/first-network/crypto-config $(BUILD_PATH)/work/$(CLIENT_NAME)/$(CLIENT_NAME)_$(CLIENT_OS)_amd64

.PHONY: shutdown
shutdown:
	cd $(FAB_PATH)/first-network && ./byfn.sh down
	-docker rm $(docker ps -a | grep dev-peer | awk '{print $1}')
	-docker rmi $(docker images | grep dev-peer | awk '{print $3}')
