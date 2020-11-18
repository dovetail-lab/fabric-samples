#!/bin/bash
# Usage: ./k8s-network.sh [ start|shutdown|clean ]

OP_PATH=${HOME}/fabric-operation
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"; echo "$(pwd)")"
CMD=$1

function waitForPeers {
  # check peer-1 container status
  local stat=$(kubectl get pod peer-1 -n jabil -o=jsonpath='{.status.phase}')
  local retry=1
  until [ ${stat} == "Running" ] || [ ${retry} -gt 20 ]; do
    sleep 5s
    echo -n "."
    stat=$(kubectl get pod peer-1 -n jabil -o=jsonpath='{.status.phase}')
    retry=$((${retry}+1))
  done
  echo "peer-1 container status: ${stat}"

  # verify gossip communication established
  local gossip=$(kubectl logs peer-1 -c peer -n jabil | grep "unary call completed" | grep "peer-0" | wc -l)
  retry=1
  until [ ${gossip} -gt 0 ] || [ ${retry} -gt 20 ]; do
    sleep 5s
    echo -n "."
    gossip=$(kubectl logs peer-1 -c peer -n jabil | grep "unary call completed" | grep "peer-0" | wc -l)
    retry=$((${retry}+1))
  done
  echo "peer gossip completed count: ${gossip}"    
}

function start {
  cp ${SCRIPT_DIR}/jabil.env ${OP_PATH}/config

  # create crypto
  cd ${OP_PATH}/ca
  ./bootstrap.sh -o orderer -p jabil -d

  # verify certificates by e.g.,
  # openssl x509 -in ${OP_PATH}/jabil.com/crypto/users/jack@jabil.com/msp/signcerts/jack@jabil.com-cert.pem -noout -text
  # openssl x509 -in /mnt/share/jabil.com/crypto/users/jack@jabil.com/msp/signcerts/jack@jabil.com-cert.pem -noout -text

  # create channel artifacts
  cd ${OP_PATH}/msp
  ./bootstrap.sh -o orderer -p jabil
  ./msp-util.sh start -p jabil

  # start network
  cd ${OP_PATH}/network
  ./network.sh start -o orderer -p jabil
  waitForPeers
}

function shutdown {
  # shutdown nodes and cleanup data
  cd ${OP_PATH}/network
  ./network.sh shutdown -o orderer -p jabil -d

  # shutdown artifact build tool
  cd ${OP_PATH}/msp
  ./msp-util.sh shutdown -o orderer
  ./msp-util.sh shutdown -p jabil
}

function clean {
  # cleanup CA data
  cd ${OP_PATH}/ca
  ./ca-server.sh shutdown -p orderer -d
  ./ca-server.sh shutdown -p jabil -d

  # cleanup old chaincode container and images
  cd ${OP_PATH}/network
  ./cleanup.sh delete

  # delete app config and data
  # rm ${OP_PATH}/config/jabil.env
  # rm -Rf ${OP_PATH}/jabil.com
}

if [ "${CMD}" == "shutdown" ]; then
  shutdown
elif [ "${CMD}" == "clean" ]; then
  clean
elif [ "${CMD}" == "start" ]; then
  start
else
  echo "Usage: ./k8s-network.sh [ start|shutdown|clean ]"
fi
