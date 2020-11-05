#!/bin/bash
# restart fabric sample first-network, including CA servers without TLS

FAB_PATH=${1:-"${FAB_PATH}"}
cd ${FAB_PATH}/test-network

function renameCerts {
  local certs=$(find organizations/peerOrganizations -name cert.pem | grep users)
  for f in ${certs}; do
    echo "rename ${f}"
    local token=${f##*/users/}
    token=${token%%/*}
    local newfile=${f/cert.pem/${token}-cert.pem}
    echo "new file ${newfile}"
    mv ${f} ${newfile}
  done
}

# start test-network with CA
./network.sh up createChannel -ca -s couchdb

# must rename user cert.pem with org prefix for fabric-sdk-go to work
renameCerts
