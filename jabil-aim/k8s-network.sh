#!/bin/bash
# Usage: ./k8s-network.sh [ start|shutdown|clean ]

OP_PATH=${HOME}/dovetail-contrib/hyperledger-fabric/operation
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"; echo "$(pwd)")"
CMD=$1

function waitForCA {
  local ups=$(kubectl get pod | egrep 'ca-client|ca-server|tlsca-server' | grep Running | wc -l)
  local retry=1
  until [ ${ups} -ge 3 ] || [ ${retry} -gt 20 ]; do
    sleep 5s
    echo -n "."
    ups=$(kubectl get pod | egrep 'ca-client|ca-server|tlsca-server' | grep Running | wc -l)
    retry=$((${retry}+1))
  done
  echo "CA container count: ${ups}"
}

function waitForTool {
  local stat=$(kubectl get pod tool -o=jsonpath='{.status.phase}')
  local retry=1
  until [ ${stat} == "Running" ] || [ ${retry} -gt 40 ]; do
    sleep 5s
    echo -n "."
    stat=$(kubectl get pod tool -o=jsonpath='{.status.phase}')
    retry=$((${retry}+1))
  done
  echo "Tool container status: ${stat}"
}

function waitForPeers {
  # check peer-1 container status
  local stat=$(kubectl get pod peer-1 -o=jsonpath='{.status.phase}')
  local retry=1
  until [ ${stat} == "Running" ] || [ ${retry} -gt 20 ]; do
    sleep 5s
    echo -n "."
    stat=$(kubectl get pod peer-1 -o=jsonpath='{.status.phase}')
    retry=$((${retry}+1))
  done
  echo "peer-1 container status: ${stat}"

  # verify gossip communication established
  local gossip=$(kubectl logs peer-1 -c peer | grep "unary call completed" | grep "peer-0" | wc -l)
  retry=1
  until [ ${gossip} -ge 2 ] || [ ${retry} -gt 20 ]; do
    sleep 5s
    echo -n "."
    gossip=$(kubectl logs peer-1 -c peer | grep "unary call completed" | grep "peer-0" | wc -l)
    retry=$((${retry}+1))
  done
  echo "peer gossip completed count: ${gossip}"    
}

function start {
  cp ${SCRIPT_DIR}/jabil.env ${OP_PATH}/config

  # create jabil namespace of kubernetes
  cd ${OP_PATH}/namespace
  ./k8s-namespace.sh create -p jabil

  # create crypto
  cd ${OP_PATH}/ca
  ./ca-server.sh start -p jabil
  waitForCA
  ./ca-crypto.sh bootstrap -p jabil
  ./ca-server.sh shutdown -p jabil -d

  # verify certificates by e.g.,
  # openssl x509 -in ${OP_PATH}/jabil.com/crypto/Users/jack@jabil.com/msp/signcerts/jack@jabil.com-cert.pem -noout -text
  # openssl x509 -in /mnt/share/jabil.com/crypto/users/jack@jabil.com/msp/signcerts/jack@jabil.com-cert.pem -noout -text

  # create channel artifacts
  cd ${OP_PATH}/msp
  ./msp-util.sh start -p jabil
  waitForTool
  ./msp-util.sh bootstrap -p jabil

  # start network
  cd ${OP_PATH}/network
  ./network.sh start -p jabil
  waitForPeers
}

function shutdown {
  # shutdown nodes and cleanup data
  cd ${OP_PATH}/network
  ./network.sh shutdown -p jabil -d

  # shutdown artifact build tool
  cd ${OP_PATH}/msp
  ./msp-util.sh shutdown -p jabil

  # shutdown CA, but keep data
  cd ${OP_PATH}/ca
  ./ca-server.sh shutdown -p jabil
}

function clean {
  # cleanup CA data
  cd ${OP_PATH}/ca
  ./ca-server.sh shutdown -p jabil -d

  # delete app config and data
  rm ${OP_PATH}/config/jabil.env
  rm -Rf ${OP_PATH}/jabil.com

  # cleanup old chaincode container and images
  cd ${OP_PATH}/network
  ./cleanup.sh delete
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
