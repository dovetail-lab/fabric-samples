# marble

This example uses [TIBCO Flogo® Enterprise](https://www.tibco.com/products/tibco-flogo) to implement the [Hyperledger Fabric](https://www.hyperledger.org/projects/fabric) sample chaincode [marbles02](https://github.com/hyperledger/fabric-samples/tree/release-1.4/chaincode/marbles02/go). This sample demonstrates basic features of the Hyperledger Fabric, including creeation and update of states and composite-keys, and different types of queries for state and history with pagination. It is implemented using [Flogo®](https://www.flogo.io/) models by visual programming with zero-code. The Flogo® models can be created, imported, edited, and/or exported by using [TIBCO Flogo® Enterprise 2.10.0](https://docs.tibco.com/products/tibco-flogo-enterprise-2-10-0).

## Prerequisite

Follow the instructions [here](https://github.com/dovetail-lab/fabric-cli) to setup the Dovetail development environment on Mac or Linux.

## Edit smart contract (optional)

Skip to the next section if you do not plan to modify the included sample model.

- Start TIBCO Flogo® Enterprise.
- Open <http://localhost:8090> in Chrome web browser.
- Create new Flogo App and rename it to `marble`. Select `Import app` to import the model [`marble.json`](marble.json)
- You can then add or update contract transactions using the Web UI of the TIBCO Flogo® Enterprise.
- After you are done editing, export the Flogo App, and copy the downloaded model file, i.e., [`marble.json`](marble.json) to this `marble` sample folder.

## Build and deploy chaincode to Hyperledger Fabric

- In this `marble` sample folder, execute `make build` to create the chaincode source code from the flogo model [`marble.json`](marble.json).
- Execute `make deploy` to deploy the chaincode to the folder `/path/to/dovetail-lab/hyperledger/fabric-samples/chaincode`.

The detailed commands of the above steps are as follows:

```bash
cd /path/to/dovetail-lab/fabric-samples/marble
make build
make deploy
```

The `build` script uses a `dovetail-tools` docker container to build and package the chaincode model into `marble_cc_1.0.tar.gz` that can be installed on any fabric network.

## Install and test chaincode using fabric test network

Start Hyperledger Fabric test-network with CouchDB:

```bash
cd /path/to/dovetail-lab/fabric-samples/marble
make start
```

Use `cli` docker container to install, approve and commit the `marble_cc` chaincode.

```bash
cd /path/to/dovetail-lab/fabric-samples/marble
make cli-init
```

Optionally, test the chaincode from `cli` docker container, i.e.,

```bash
cd /path/to/dovetail-lab/fabric-samples/marble
make cli-test
```

You may skip this test, and follow the steps in the next section to build client apps, and then use the client app to execute the tests. If you run the `cli` tests, however, it should print out 17 successful tests with status code `200` if the `marble_cc` chaincode is installed and instantiated successfully on the Fabric test-network.

Note that developers can also use Fabric dev-mode to test chaincode (refer [dev](./dev.md) for more details).

## Edit marble REST service (optional)

The sample Flogo model, [`marble-client.json`](marble-client.json) is a REST service that invokes the `marble_cc` chaincode. Skip to the next section if you do not plan to modify the sample model.

The client app requires the metadata of the `marble_cc` chaincode. You can re-generate the contract metadata [`metadata.json`](contract-metadata/metadata.json) by

```bash
cd /path/to/dovetail-lab/fabric-samples/marble
make metadata
```

Following are steps to edit or view the REST service models:

- Start TIBCO Flogo® Enterprise.
- Open <http://localhost:8090> in Chrome web browser.
- Create new Flogo App and rename it to `marble-client`, then select `Import app` to import the model [`marble-client.json`](marble-client.json)
- You can then add or update application flows using the Web UI of the TIBCO Flogo® Enterprise.
- Open `Connections` tab, find and edit the `marble client` connector. Set the `Smart contract metadata file` to the [`metadata.json`](contract-metadata/metadata.json). Set the `Network configuration file` and `entity matcher file` to the corresponding files in [`testdata`](../testdata).
- After you are done editing, export the Flogo App, and copy the downloaded model file, i.e., [`marble-client.json`](marble-client.json) to the `marble` sample folder.

Note: after you import the REST model, check the configuration of the REST trigger. The port should be mapped to `=$property["PORT"]`. Correcct the mapping if it is not imported correctly.

## Build and start the marble REST service

Build and start the client app as follows:

```bash
cd /path/to/dovetail-lab/fabric-samples/marble
make build-client
make run
```

Note that the flow model `marble-fe.json` is similar to the `marble-client.json` used above, except that it uses the Flogo Enterprise `REST` trigger, which is not open-source, and thus requires license for TIBCO Flogo Enterprise. You can build and run this model similarly, i.e.,

```bash
cd /path/to/dovetail-lab/fabric-samples/marble
make build-fe-client
make run
```

## Test marble REST service and marble chaincode

The REST service implements the following APIs to invoke corresponding blockchain transactions of the `marble` chaincode:

- **Create Marble** (PUT): it creates a new marble.
- **Transfer Marble** (PUT): it transfers a marble to a new owner.
- **Transfer By Color** (PUT): it transfers all marbles of a specified color to a new owner.
- **Delete Marble** (DELETE): it deletes the state of a specified marble.
- **Get Marble** (GET): it retrieves a marble record by its key.
- **Query By Owner** (GET): it queries marble records by an owner name.
- **Query By Range** (GET): it retrieves marble records in a specified range of keys.
- **Marble History** (GET): it retrieves the history of a marble.
- **Query Range Page** (GET): it retrieves marble records in a range of keys, with pagination support.

You can use the test messages in [marble.postman_collection.json](marble.postman_collection.json) for end-to-end tests. The test file can be imported and executed in [postman](https://www.getpostman.com/downloads/).

If you prefer, you can also use the following `curl` commands to invoke the REST APIs:

```bash
# insert test data
curl -H 'Content-Type: application/json' -X PUT -d '{"name":"marble21","color":"blue","size":35,"owner":"tom"}' http://localhost:8989/marble/create
curl -H 'Content-Type: application/json' -X PUT -d '{"name":"marble22","color":"red","size":50,"owner":"tom"}' http://localhost:8989/marble/create
curl -H 'Content-Type: application/json' -X PUT -d '{"name":"marble23","color":"blue","size":70,"owner":"tom"}' http://localhost:8989/marble/create
curl -H 'Content-Type: application/json' -X PUT -d '{"name":"marble24","color":"purple","size":80,"owner":"tom"}' http://localhost:8989/marble/create
curl -H 'Content-Type: application/json' -X PUT -d '{"name":"marble25","color":"purple","size":90,"owner":"tom"}' http://localhost:8989/marble/create
curl -H 'Content-Type: application/json' -X PUT -d '{"name":"marble26","color":"purple","size":100,"owner":"tom"}' http://localhost:8989/marble/create
curl -X GET http://localhost:8989/marble/key/marble22
curl -X GET "http://localhost:8989/marble/range?startKey=marble21&endKey=marble25"

# transfer marble ownership
curl -H 'Content-Type: application/json' -X PUT -d '{"name":"marble22","newOwner":"jerry"}' http://localhost:8989/marble/transfer
curl -H 'Content-Type: application/json' -X PUT -d '{"color":"blue","newOwner":"jerry"}' http://localhost:8989/marble/transfercolor
curl -X GET http://localhost:8989/marble/owner/jerry
curl -X GET "http://localhost:8989/marble/range?startKey=marble21&endKey=marble25"

# delete marble state, not history
curl -X DELETE http://localhost:8989/marble/delete/marble21
curl -X GET http://localhost:8989/marble/history/marble21

# query pagination using page-size and starting bookmark
curl -X GET "http://localhost:8989/marble/rangepage?startKey=marble21&endKey=marble27&pageSize=3"
curl -X GET "http://localhost:8989/marble/rangepage?startKey=marble21&endKey=marble27&pageSize=3&bookmark=marble5"
```

You can use couchdb UI to view the current states via [http://localhost:5984/\_utils](http://localhost:5984/_utils)

## Notes on GraphQL service

The previous step `make package` generated a `GraphQL` schema file [`metadata.gql`](contract-metadata/metadata.gql), which can be used to implement a GraphQL service to invoke the `marble` chaincode. Refer to the [`equipment sample`](../equipment) for steps of creating a GraphQL service with zero-code.

## Cleanup the Hyplerledger Fabric test network

After you are done testing, you can stop and cleanup the Fabric `test-network` as follows:

```bash
cd /path/to/dovetail-lab/fabric-samples/marble
make shutdown
```

## Deploy to IBM Cloud

Dovetail release v1.0.0 builds chaincode into CDS package, `marble_cc_1.0.cds`, which can be deployed to IBM Blockchain Platform. Refer to [fabric-tools](https://github.com/dovetail-lab/fabric-cli/tree/master/fabric-tools) for details about installing chaincode on the IBM Blockchain Platform.

The REST or GraphQL service apps can access the same `marble` chaincode deployed in [IBM Cloud](https://cloud.ibm.com) using the [IBM Blockchain Platform](https://cloud.ibm.com/catalog/services/blockchain-platform-20). The only required update is the network configuration file. [config_ibp.yaml](../testdata/config_ibp.yaml) is a sample network configuration that can be used by the REST or GraphQL service app.

## Deploy to other cloud

You can also deploy and test chaincode or applications in a Kubernetes cluster by other cloud service providers, e.g., Amazon AWS, Microsoft Azure, or Google GCP. The scripts in the [fabric-operation](https://github.com/dovetail-lab/fabric-operation) project can be used to create Kubernetes clusters and manage Hyperledger Fabric networks in each of the 3 major cloud service providers. Even though AWS and Azure provide their own managed service for Hyperledger Fabric, they do not support the latest version of the fabric release, e.g., release v1.4.9, and thus you may need to manage your own clusters in a cloud provider other than IBM.
