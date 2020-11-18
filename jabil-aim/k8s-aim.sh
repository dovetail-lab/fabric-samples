#!/bin/bash
# Usage: ./k8s-aim.sh [ deploy|shutdown ]

OP_PATH=${HOME}/dovetail-lab/fabric-operation
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"; echo "$(pwd)")"
CMD=$1

function deploy {
  # package chaincode
  cd ${OP_PATH}/msp
  ./msp-util.sh build-cds -m ${SCRIPT_DIR}/jabil_aim.json -p jabil

  # create and join channel
  cd ${OP_PATH}/network
  ./network.sh create-channel -c mychannel -o orderer -p jabil
  ./network.sh join-channel -n peer-0 -c mychannel -o orderer -p jabil -a
  ./network.sh join-channel -n peer-1 -c mychannel -o orderer -p jabil

  # install and commit chaincode
  ./network.sh install-chaincode -n peer-0 -f jabil_aim_cc_1.0.tar.gz -p jabil
  ./network.sh install-chaincode -n peer-1 -f jabil_aim_cc_1.0.tar.gz -p jabil >log.txt
  local packageID=$(cat log.txt | grep "Chaincode code package identifier:" | sed 's/.*Chaincode code package identifier: //' | tr -d '\r')
  ./network.sh approve-chaincode -p jabil -c mychannel -k ${packageID} -s jabil_aim_cc
  sleep 5
  ./network.sh commit-chaincode -p jabil -c mychannel -s jabil_aim_cc

  # configure client network
  cd ${OP_PATH}/service
  ./gateway.sh config -c mychannel -o orderer -p jabil

  # build and start client service
  cd ${OP_PATH}/dovetail
  ./dovetail.sh config-app -m ${SCRIPT_DIR}/aim_rest.json -c mychannel -p jabil
  ./dovetail.sh start-app -m aim_rest.json -p jabil
}

function shutdown {
  cd ${OP_PATH}/dovetail
  # shutdown and delete executable (-d flag), so it'll be rebuilt on next restart
  ./dovetail.sh stop-app -m aim_rest.json -d -p jabil
}

if [ "${CMD}" == "deploy" ]; then
  deploy
elif [ "${CMD}" == "shutdown" ]; then
  shutdown
else
  echo "Usage: ./k8s-aim.sh [ deploy|shutdown ]"
fi
