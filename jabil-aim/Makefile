MAKEFILE_THIS := $(lastword $(MAKEFILE_LIST))
SRC_PATH      := $(patsubst %/,%,$(dir $(abspath $(MAKEFILE_THIS))))
APP_FILE      := jabil_aim.json
APP_NAME      := jabil_aim_cc

LAB_PATH      ?= $(SRC_PATH)/../..
BUILD_PATH    := $(LAB_PATH)/fabric-cli/scripts
FAB_PATH      ?= $(LAB_PATH)/hyperledger/fabric-samples
CC_DEPLOY     := $(FAB_PATH)/chaincode

CLIENT_FILE   := aim_rest.json
CLIENT_NAME   := aim_rest
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
	cp $(BUILD_PATH)/work/$(APP_NAME)/$(APP_NAME)_1.0.tar.gz $(CC_DEPLOY)/$(APP_NAME)
	cp collections_config.json $(CC_DEPLOY)/$(APP_NAME)
	cp fn-cli-init.sh $(FAB_PATH)/test-network/fn-init-aim.sh
	cp fn-cli-test.sh $(FAB_PATH)/test-network/fn-test-aim.sh

.PHONY: start
start: test-network
	./start-fn.sh $(FAB_PATH)
	./gen-user.sh $(FAB_PATH) jack@jabil.com 1
	./gen-user.sh $(FAB_PATH) jill@jabil.com 1
	./gen-user.sh $(FAB_PATH) isaac@intel.com 1
	./gen-user.sh $(FAB_PATH) iris@intel.com 1
	./gen-user.sh $(FAB_PATH) alice@apple.com 1
	./gen-user.sh $(FAB_PATH) adam@apple.com 1
	./gen-user.sh $(FAB_PATH) nancy@nxp.com 1
	./gen-user.sh $(FAB_PATH) nick@nxp.com 1
	./gen-user.sh $(FAB_PATH) henry@hitachi.com 1
	./gen-user.sh $(FAB_PATH) helen@hitachi.com 1

.PHONY: test-network
test-network: $(FAB_PATH)/test-network/network.sh
	cp $(SRC_PATH)/../testdata/docker-compose-cli.yaml $(FAB_PATH)/test-network/docker
	sed -i -e "s/COMPOSE_FILE_BASE=docker\/docker-compose-test-net.yaml.*/COMPOSE_FILE_BASE=\"docker\/docker-compose-test-net.yaml -f docker\/docker-compose-cli.yaml\"/" $(FAB_PATH)/test-network/network.sh

.PHONY: shutdown
shutdown:
	cd $(FAB_PATH)/test-network && ./network.sh down

.PHONY: cli-init
cli-init:
	docker exec cli bash -c './fn-init-aim.sh'

.PHONY: cli-test
cli-test:
	docker exec cli bash -c './fn-test-aim.sh'

.PHONY: metadata
metadata:
	mkdir -p $(SRC_PATH)/contract-metadata
	fabric-tools metadata -f $(APP_FILE) -m $(SRC_PATH)/contract-metadata/metadata.json -g $(SRC_PATH)/contract-metadata/metadata.gql -o $(SRC_PATH)/contract-metadata/override.json

.PHONY: gen-swagger
gen-swagger:
	protoc -I=. -I=$(LAB_PATH)/fabric-operation/service/src/proto \
		--openapiv2_out . \
		--openapiv2_opt logtostderr=true \
		./aim.proto

.PHONY: grpc-gateway
grpc-gateway:
	cd $(LAB_PATH)/fabric-operation/service/tools && go install \
		github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway \
		github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2 \
		google.golang.org/protobuf/cmd/protoc-gen-go \
		google.golang.org/grpc/cmd/protoc-gen-go-grpc

.PHONY: clean-client
clean-client:
	rm -Rf $(BUILD_PATH)/work/$(CLIENT_NAME)

.PHONY: build-client
build-client: $(CLIENT_FILE) clean-client
	$(BUILD_PATH)/build.sh client -f $(CLIENT_FILE) -n $(CLIENT_NAME) -s $(CLIENT_OS)

.PHONY: run
run:
	FLOGO_APP_PROP_RESOLVERS=env FLOGO_APP_PROPS_ENV=auto PORT=8989 FLOGO_LOG_LEVEL=DEBUG FLOGO_SCHEMA_SUPPORT=true FLOGO_SCHEMA_VALIDATION=false CRYPTO_PATH=$(FAB_PATH)/test-network/organizations $(BUILD_PATH)/work/$(CLIENT_NAME)/$(CLIENT_NAME)_$(CLIENT_OS)_amd64
