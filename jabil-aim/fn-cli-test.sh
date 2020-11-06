#!/bin/bash

# jabil_aim_cc tests executed from cli docker container of the Fabric test-network
. ./scripts/envVar.sh
setGlobals 1
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051

export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/test-network/organizations/peerOrganizations/org1.example.com/users/jack\@org1.example.com/msp
APP_NAME=jabil_aim_cc

ORDERER_ARGS="-o orderer.example.com:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile $ORDERER_CA"
ORG1_ARGS="--peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles $PEER0_ORG1_CA"
ORG2_ARGS="--peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles $PEER0_ORG2_CA"

# test creation
peer chaincode invoke $ORDERER_ARGS -C mychannel -n ${APP_NAME} $ORG1_ARGS $ORG2_ARGS -c '{"function":"PutSupplier","Args":["{\"SupplierID\":\"s0\"}"]}'
peer chaincode invoke $ORDERER_ARGS -C mychannel -n ${APP_NAME} $ORG1_ARGS $ORG2_ARGS -c '{"function":"PutAgreement","Args":["{\"AgreementID\": \"a0\",\"SupplierID\": \"s0\",\"IsPrimary\": true,\"SignatureDate\": \"2020-04-15\",\"SignedBy\": \"jabil\",\"StartDate\": \"2020-01-01\",\"EndDate\": \"2020-12-31\",\"CollectionFrequency\": \"QUARTERLY\",\"Type\": \"FIXED_RATE\",\"StandardTerms\": [{\"MinSaleAmt\": 10000,\"BonusPct\": 0.1}]}"]}'
peer chaincode invoke $ORDERER_ARGS -C mychannel -n ${APP_NAME} $ORG1_ARGS $ORG2_ARGS -c '{"function":"PutPurchases","Args":["[{\"PurchaseOrderNbr\": \"po-0\",\"SupplierID\": \"s0\",\"DocumentID\": \"po-0\",\"DocumentDate\": \"2020-03-01\",\"ManufacturerPartNbr\": \"item-1\",\"SalePriceUSD\": 1000,\"VerifiedBy\": \"jabil\"},{\"PurchaseOrderNbr\": \"po-0\",\"SupplierID\": \"s0\",\"DocumentID\": \"po-0\",\"DocumentDate\": \"2020-03-01\",\"ManufacturerPartNbr\": \"item-2\",\"SalePriceUSD\": 2000,\"VerifiedBy\": \"jabil\"}]"]}'
peer chaincode invoke $ORDERER_ARGS -C mychannel -n ${APP_NAME} $ORG1_ARGS $ORG2_ARGS -c '{"function":"PutBulkLoad","Args":["{\"BulkLoadID\":\"load0\",\"ReferenceFile\":\"load0.xls\",\"ReferenceHash\":\"1baee9df696a76fabb954114a02ff200bd1974b0\",\"LoadedBy\":\"jabil\"}"]}'
peer chaincode invoke $ORDERER_ARGS -C mychannel -n ${APP_NAME} $ORG1_ARGS $ORG2_ARGS -c '{"function":"PutMonthlyPurchase","Args":["{\"SupplierID\": \"s0\",\"Year\": 2019,\"Month\": 1,\"PurchaseAmt\": 15000}"]}'

# test query
sleep 5
peer chaincode query -C mychannel -n ${APP_NAME} -c '{"Args":["GetSupplier","s0"]}'
peer chaincode query -C mychannel -n ${APP_NAME} -c '{"Args":["GetAgreement","a0"]}'
peer chaincode query -C mychannel -n ${APP_NAME} -c '{"Args":["GetPurchasesPerSupplier","s0","jabil","2020","3"]}'
peer chaincode query -C mychannel -n ${APP_NAME} -c '{"Args":["GetBulkLoad","load0"]}'
peer chaincode query -C mychannel -n ${APP_NAME} -c '{"Args":["GetMonthlyPurchases","s0","2019"]}'

# test bonus calculation
peer chaincode invoke $ORDERER_ARGS -C mychannel -n ${APP_NAME} $ORG1_ARGS $ORG2_ARGS -c '{"function":"PutMonthlyPurchase","Args":["{\"SupplierID\": \"s0\",\"Year\": 2018,\"Month\": 1,\"PurchaseAmt\": 1000}"]}'
peer chaincode invoke $ORDERER_ARGS -C mychannel -n ${APP_NAME} $ORG1_ARGS $ORG2_ARGS -c '{"function":"PutMonthlyPurchase","Args":["{\"SupplierID\": \"s0\",\"Year\": 2018,\"Month\": 2,\"PurchaseAmt\": 1000}"]}'
peer chaincode invoke $ORDERER_ARGS -C mychannel -n ${APP_NAME} $ORG1_ARGS $ORG2_ARGS -c '{"function":"PutMonthlyPurchase","Args":["{\"SupplierID\": \"s0\",\"Year\": 2018,\"Month\": 3,\"PurchaseAmt\": 1000}"]}'
peer chaincode invoke $ORDERER_ARGS -C mychannel -n ${APP_NAME} $ORG1_ARGS $ORG2_ARGS -c '{"function":"PutMonthlyPurchase","Args":["{\"SupplierID\": \"s0\",\"Year\": 2018,\"Month\": 4,\"PurchaseAmt\": 1000}"]}'
peer chaincode invoke $ORDERER_ARGS -C mychannel -n ${APP_NAME} $ORG1_ARGS $ORG2_ARGS -c '{"function":"PutMonthlyPurchase","Args":["{\"SupplierID\": \"s0\",\"Year\": 2018,\"Month\": 5,\"PurchaseAmt\": 1000}"]}'
peer chaincode invoke $ORDERER_ARGS -C mychannel -n ${APP_NAME} $ORG1_ARGS $ORG2_ARGS -c '{"function":"PutMonthlyPurchase","Args":["{\"SupplierID\": \"s0\",\"Year\": 2018,\"Month\": 6,\"PurchaseAmt\": 1000}"]}'

peer chaincode invoke $ORDERER_ARGS -C mychannel -n ${APP_NAME} $ORG1_ARGS $ORG2_ARGS -c '{"function":"PutMonthlyPurchase","Args":["{\"SupplierID\": \"s0\",\"Year\": 2019,\"Month\": 1,\"PurchaseAmt\": 1000}"]}'
peer chaincode invoke $ORDERER_ARGS -C mychannel -n ${APP_NAME} $ORG1_ARGS $ORG2_ARGS -c '{"function":"PutMonthlyPurchase","Args":["{\"SupplierID\": \"s0\",\"Year\": 2019,\"Month\": 2,\"PurchaseAmt\": 1100}"]}'
peer chaincode invoke $ORDERER_ARGS -C mychannel -n ${APP_NAME} $ORG1_ARGS $ORG2_ARGS -c '{"function":"PutMonthlyPurchase","Args":["{\"SupplierID\": \"s0\",\"Year\": 2019,\"Month\": 3,\"PurchaseAmt\": 1200}"]}'
peer chaincode invoke $ORDERER_ARGS -C mychannel -n ${APP_NAME} $ORG1_ARGS $ORG2_ARGS -c '{"function":"PutMonthlyPurchase","Args":["{\"SupplierID\": \"s0\",\"Year\": 2019,\"Month\": 4,\"PurchaseAmt\": 1300}"]}'
peer chaincode invoke $ORDERER_ARGS -C mychannel -n ${APP_NAME} $ORG1_ARGS $ORG2_ARGS -c '{"function":"PutMonthlyPurchase","Args":["{\"SupplierID\": \"s0\",\"Year\": 2019,\"Month\": 5,\"PurchaseAmt\": 1400}"]}'
peer chaincode invoke $ORDERER_ARGS -C mychannel -n ${APP_NAME} $ORG1_ARGS $ORG2_ARGS -c '{"function":"PutMonthlyPurchase","Args":["{\"SupplierID\": \"s0\",\"Year\": 2019,\"Month\": 6,\"PurchaseAmt\": 1500}"]}'

peer chaincode invoke $ORDERER_ARGS -C mychannel -n ${APP_NAME} $ORG1_ARGS $ORG2_ARGS -c '{"function":"PutAgreement","Args":["{\"AgreementID\": \"a0\",\"SupplierID\": \"s0\",\"IsPrimary\": true,\"SignatureDate\": \"2018-01-01\",\"SignedBy\": \"jabil\",\"StartDate\": \"2018-01-01\",\"EndDate\": \"2020-12-31\",\"CollectionFrequency\": \"QUARTERLY\",\"Type\": \"FIXED_RATE\",\"StandardTerms\": [{\"MinSaleAmt\": 3000,\"BonusPct\": 0.1}]}"]}'
sleep 5
peer chaincode invoke $ORDERER_ARGS -C mychannel -n ${APP_NAME} $ORG1_ARGS $ORG2_ARGS -c '{"function":"PutAgreement","Args":["{\"AgreementID\": \"a1\",\"SupplierID\": \"s0\",\"IsPrimary\": true,\"SignatureDate\": \"2018-01-01\",\"SignedBy\": \"jabil\",\"StartDate\": \"2018-01-01\",\"EndDate\": \"2020-12-31\",\"CollectionFrequency\": \"SEMI-ANNUALLY\",\"Type\": \"FIXED_RATE\",\"StandardTerms\": [{\"MinSaleAmt\": 6000,\"BonusPct\": 0.1}]}"]}'
sleep 5
peer chaincode invoke $ORDERER_ARGS -C mychannel -n ${APP_NAME} $ORG1_ARGS $ORG2_ARGS -c '{"function":"PutAgreement","Args":["{\"AgreementID\": \"a2\",\"SupplierID\": \"s0\",\"IsPrimary\": true,\"SignatureDate\": \"2018-01-01\",\"SignedBy\": \"jabil\",\"StartDate\": \"2018-01-01\",\"EndDate\": \"2020-12-31\",\"CollectionFrequency\": \"QUARTERLY\",\"Type\": \"STARDARD_STEP\",\"StandardTerms\": [{\"MinSaleAmt\": 3000,\"BonusPct\": 0.1},{\"MinSaleAmt\": 3500,\"BonusPct\": 0.05}]}"]}'
sleep 5
peer chaincode invoke $ORDERER_ARGS -C mychannel -n ${APP_NAME} $ORG1_ARGS $ORG2_ARGS -c '{"function":"PutAgreement","Args":["{\"AgreementID\": \"a3\",\"SupplierID\": \"s0\",\"IsPrimary\": true,\"SignatureDate\": \"2018-01-01\",\"SignedBy\": \"jabil\",\"StartDate\": \"2018-01-01\",\"EndDate\": \"2020-12-31\",\"CollectionFrequency\": \"SEMI-ANNUALLY\",\"Type\": \"STARDARD_STEP\",\"StandardTerms\": [{\"MinSaleAmt\": 6000,\"BonusPct\": 0.1},{\"MinSaleAmt\": 7000,\"BonusPct\": 0.05}]}"]}'
sleep 5
peer chaincode invoke $ORDERER_ARGS -C mychannel -n ${APP_NAME} $ORG1_ARGS $ORG2_ARGS -c '{"function":"PutAgreement","Args":["{\"AgreementID\": \"a4\",\"SupplierID\": \"s0\",\"IsPrimary\": true,\"SignatureDate\": \"2018-01-01\",\"SignedBy\": \"jabil\",\"StartDate\": \"2018-01-01\",\"EndDate\": \"2020-12-31\",\"CollectionFrequency\": \"QUARTERLY\",\"Type\": \"BASELINE_GROWTH\",\"GrowthTerms\": [{\"MinSaleGrowth\": 1.1,\"BonusPct\": 0.1},{\"MinSaleGrowth\": 1.2,\"BonusPct\": 0.05}]}"]}'
sleep 5
peer chaincode invoke $ORDERER_ARGS -C mychannel -n ${APP_NAME} $ORG1_ARGS $ORG2_ARGS -c '{"function":"PutAgreement","Args":["{\"AgreementID\": \"a5\",\"SupplierID\": \"s0\",\"IsPrimary\": true,\"SignatureDate\": \"2018-01-01\",\"SignedBy\": \"jabil\",\"StartDate\": \"2018-01-01\",\"EndDate\": \"2020-12-31\",\"CollectionFrequency\": \"SEMI-ANNUALLY\",\"Type\": \"BASELINE_GROWTH\",\"GrowthTerms\": [{\"MinSaleGrowth\": 1.1,\"BonusPct\": 0.1},{\"MinSaleGrowth\": 1.2,\"BonusPct\": 0.05}]}"]}'
sleep 5

echo "a0 - Q1, Q2; a1 - H1 bonus: should be 30, 120, 150"
peer chaincode query -C mychannel -n ${APP_NAME} -c '{"Args":["CalculateRebate","s0","a0","2019","1"]}'
peer chaincode query -C mychannel -n ${APP_NAME} -c '{"Args":["CalculateRebate","s0","a0","2019","2"]}'
peer chaincode query -C mychannel -n ${APP_NAME} -c '{"Args":["CalculateRebate","s0","a1","2019","1"]}'

echo "a2 - Q1, Q2; a3 - H1 bonus: should be 30, 155, 175"
peer chaincode query -C mychannel -n ${APP_NAME} -c '{"Args":["CalculateRebate","s0","a2","2019","1"]}'
peer chaincode query -C mychannel -n ${APP_NAME} -c '{"Args":["CalculateRebate","s0","a2","2019","2"]}'
peer chaincode query -C mychannel -n ${APP_NAME} -c '{"Args":["CalculateRebate","s0","a3","2019","1"]}'

echo "a4 - Q1, Q2; a5 - H1 bonus: shouls be 0, 120, 105"
peer chaincode query -C mychannel -n ${APP_NAME} -c '{"Args":["CalculateRebate","s0","a4","2019","1"]}'
peer chaincode query -C mychannel -n ${APP_NAME} -c '{"Args":["CalculateRebate","s0","a4","2019","2"]}'
peer chaincode query -C mychannel -n ${APP_NAME} -c '{"Args":["CalculateRebate","s0","a5","2019","1"]}'

# test delete purchase
peer chaincode invoke $ORDERER_ARGS -C mychannel -n ${APP_NAME} $ORG1_ARGS $ORG2_ARGS -c '{"function":"DeletePurchase","Args":["po-0","item-1"]}'
