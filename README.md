# Zero-code development samples for Hyperledger Fabric

This package includes sample Hyperledger Fabric apps using the Flogo visual programming environment with the Dovetail-lab's extensions.

## Getting Started

Follow the instructions [here](https://github.com/dovetail-lab/fabric-cli) to setup the local environment on Mac or Linux for Hyperledger Fabric development, then, start by looking at the following end-to-end samples:

- [`marble`](./marble), which is a zero-code version of the `marbles02` chaincode in [`fabric samples`](https://github.com/hyperledger/fabric-samples/tree/release-1.4/chaincode) and a REST service for users to submit chaincode transactions. It demonstrates basic features of the Hyperledger Fabric, including the creeation and update of states and composite-keys, and various types of queries for state and history with pagination.
- [`marble-private`](./marble-private), which is a zero-code version of the `marbles02_private` chaincode in [`fabric samples`](https://github.com/hyperledger/fabric-samples/tree/release-1.4/chaincode) and a REST service. It demonstrates the use of private data collections.
- [`equipment`](./equipment), which implements the chaincode and REST and GraphQL services for tracking equipment purchases and installations coordinated by multiple clients. It demonstrates the use of Hyperledger Fabric events and event listener.
- [`audit`](./audit) is an audit-trace app used by the TIBCO AuditSafe cloud service. It supports multi-tenant multi-domain audit logs and reporting requirements.
- [`iou`](./iou) is an advanced sample that implements a cross-border payment network similar to a simplified [Ripple network](https://www.ripple.com/files/ripple_product_overview.pdf). It implements both a required chaincode and a client app with [GraphQL](https://graphql.org/) service interface. The chaincode uses a few more advanced Hyperledger Fabric features, including ABAC and private data collections. This sample illustrates how a real-worlld Hyperleddger Fabric app can be implemented with zero-code.
- [`jabil-aim`](./jabil-aim) is a demo for supply-chain purchase order recociliation between buyer and seller, and it is used to manage the accurate calculation of credits and rewards that depend on total puraching volumes.

By comparing other implementations of chaincode and client apps, you can see that hundreds of lines of boilerplate code are replaced by a single JSON model file exported from the TIBCO Flogo® Enterprise Web UI. Besides, by using the Flogo visual programming environment, you do not have to learn much of the blockchain APIs nor special programming language for smart contracts. You can implement chaincode and client apps for Hyperledger Fabric by simple drag-drop-mapping in Flogo.

## Modeling with TIBCO Cloud Integration (TCI)

If you are already a subscriber of [TIBCO Cloud Integration (TCI)](https://cloud.tibco.com/), or you plan to sign-up for a TCI trial, you can easily start the development of Hyperledger Fabric apps by using a Chrome browser.

## Deploy to Kubernetes in Cloud

Dovetail apps and chaincodes can be deployed to Kubernetes in any of the supported cloud services, including AWS, Azure, and GCP. Refer to [fabric-operation](https://github.com/dovetail-lab/fabric-operation) for detailed instructions about creating Kubernetes clusters and managing Hyperledger Fabric network and chaincodes.
