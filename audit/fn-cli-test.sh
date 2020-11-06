#!/bin/bash

# audit_cc tests executed from cli docker container of the Fabric sample first-network
APP_NAME=audit_cc

. ./scripts/envVar.sh
setGlobals 1
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051

ORDERER_ARGS="-o orderer.example.com:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile $ORDERER_CA"
ORG1_ARGS="--peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles $PEER0_ORG1_CA"
ORG2_ARGS="--peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles $PEER0_ORG2_CA"

# insert test data
echo "insert 4 audit logs ..."
peer chaincode invoke $ORDERER_ARGS -C mychannel -n ${APP_NAME} $ORG1_ARGS $ORG2_ARGS -c '{"function":"createAudit","Args":["[{\"recID\":\"audit1\",\"domain\":\"tibco.oocto.dovetail.test\",\"owner\":\"oocto@tibco.com\",\"data\":\"test1\",\"hashType\":\"\",\"hashValue\":\"\"},{\"recID\":\"audit2\",\"domain\":\"tibco.oocto.dovetail.test\",\"owner\":\"oocto@tibco.com\",\"data\":\"test2\",\"hashType\":\"\",\"hashValue\":\"\"}]"]}'
sleep 5
peer chaincode invoke $ORDERER_ARGS -C mychannel -n ${APP_NAME} $ORG1_ARGS $ORG2_ARGS -c '{"function":"createAudit","Args":["[{\"recID\":\"audit3\",\"domain\":\"tibco.oocto.dovetail.test\",\"owner\":\"oocto@tibco.com\",\"data\":\"test3\",\"hashType\":\"\",\"hashValue\":\"\"},{\"recID\":\"audit2\",\"domain\":\"tibco.oocto.dovetail.test\",\"owner\":\"oocto@tibco.com\",\"data\":\"test2 again\",\"hashType\":\"\",\"hashValue\":\"\"}]"]}'
sleep 5

# test query
data=$(peer chaincode query -C mychannel -n ${APP_NAME} -c '{"Args":["getRecordsByID","audit1"]}')
tx1=${data#*txID\":\"}
id1=${tx1%%\"*}

echo "query with first txID ${id1}"
peer chaincode query -C mychannel -n ${APP_NAME} -c '{"Args":["getRecord","'${id1}':audit1"]}'
peer chaincode query -C mychannel -n ${APP_NAME} -c '{"Args":["getRecordsByTxID","'${id1}'"]}'
peer chaincode query -C mychannel -n ${APP_NAME} -c '{"Args":["getRecordsByID","audit2"]}'
tx1=${data#*txTime\":\"}
tm1=${tx1%%\"*}

echo "query with first txTime ${tm1}"
peer chaincode query -C mychannel -n ${APP_NAME} -c '{"Args":["getRecordsByTxTime","'${tm1}'"]}'
today=`date +%F`
# this does not always work, so replace it
tomorrow=`date --date='1 day' +%F`
if [ "${tomorrow}" == "" ]; then
  tomorrow='3000-01-01'
fi

echo "query audit records of today ${today}"
peer chaincode query -C mychannel -n ${APP_NAME} -c '{"Args":["queryTimeRange","tibco.oocto.dovetail.test","oocto@tibco.com","'${today}'","'${tomorrow}'"]}'

# test delete
echo "delete record ${id1}:audit1"
peer chaincode invoke $ORDERER_ARGS -C mychannel -n ${APP_NAME} $ORG1_ARGS $ORG2_ARGS -c '{"function":"deleteRecord","Args":["'${id1}':audit1"]}'
sleep 5
peer chaincode query -C mychannel -n ${APP_NAME} -c '{"Args":["getRecordsByTxID","'${id1}'"]}'

echo "delete transaction ${id1}"
peer chaincode invoke $ORDERER_ARGS -C mychannel -n ${APP_NAME} $ORG1_ARGS $ORG2_ARGS -c '{"function":"deleteTransaction","Args":["'${id1}'"]}'
sleep 5
peer chaincode query -C mychannel -n ${APP_NAME} -c '{"Args":["getRecordsByTxID","'${id1}'"]}'
echo "query audit records of today ${today}"
peer chaincode query -C mychannel -n ${APP_NAME} -c '{"Args":["queryTimeRange","tibco.oocto.dovetail.test","oocto@tibco.com","'${today}'","'${tomorrow}'"]}'
