#!/bin/bash
# generate user key and cert with attribute bank, admin, alias, and email
# usage: gen-user.sh name org
#  e.g., gen-user/sh Alice 1
#  user-name ending with "Admin" acts as bank admin 

FAB_HOME=${1:-"${PWD}/../../hyperledger/fabric-samples"}
FAB_PATH=${FAB_HOME}/test-network

USER=${2:-"Alice"}
ORG_NAME=org1
PORT=7054
BANK=EURBank
if [ "$3" == "2" ]; then
  ORG_NAME=org2
  PORT=8054
  BANK=USDBank
fi
ORG=${ORG_NAME}.example.com
CANAME=ca-${ORG_NAME}
TLSCA=${FAB_PATH}/organizations/fabric-ca/${ORG_NAME}/tls-cert.pem

ADMIN="false"
if [[ "${USER}" == *Admin ]]; then
  echo "${USER} is bank admin"
  ADMIN="true"
fi

WORK=/tmp/ca
echo "generate key and cert for user ${USER}@${ORG}"

if [ -d "${WORK}" ]; then
  echo "cleanup ${WORK}"
  rm -R "${WORK}"
fi

# check CA server
docker ps | grep "hyperledger/fabric-ca" | grep "${PORT}->${PORT}/tcp"
if [ "$?" -ne 0 ]; then
  echo "CA server is not running.  Start test network with '-ca' option, e.g., './network.sh up createChannel -ca -s couchdb'."
  exit 1
fi

# check fabric-ca-client
if [ ! -f "${FAB_HOME}/bin/fabric-ca-client" ]; then
  echo "fabric-ca-client not found in ${FAB_HOME}/bin"
  exit 1
fi

# enroll CA admin
export FABRIC_CA_CLIENT_HOME=${WORK}/admin
${FAB_HOME}/bin/fabric-ca-client getcainfo -u https://localhost:${PORT} --caname ${CANAME} --tls.certfiles ${TLSCA}
openssl x509 -noout -text -in ${FABRIC_CA_CLIENT_HOME}/msp/cacerts/localhost-${PORT}.pem
${FAB_HOME}/bin/fabric-ca-client enroll -u https://admin:adminpw@localhost:${PORT} --caname ${CANAME} --tls.certfiles ${TLSCA}

# register and enroll new user
# Note: important to make id.name as user@org for signature verification!
${FAB_HOME}/bin/fabric-ca-client register --caname ${CANAME} --tls.certfiles ${TLSCA} --id.name ''"${USER}@${ORG}"'' --id.secret ${USER}pw --id.type client --id.attrs 'admin='"${ADMIN}"':ecert,alias='"${USER}"',bank='"${BANK}"',email='"${USER}@${ORG}"''
export FABRIC_CA_CLIENT_HOME=${WORK}/${USER}\@${ORG}
${FAB_HOME}/bin/fabric-ca-client enroll -u https://${USER}@${ORG}:${USER}pw@localhost:${PORT} --caname ${CANAME} --tls.certfiles ${TLSCA} --enrollment.attrs "admin,alias,bank,email" -M ${FABRIC_CA_CLIENT_HOME}/msp
openssl x509 -noout -text -in ${WORK}/${USER}\@${ORG}/msp/signcerts/cert.pem

# copy key and cert to test-network orgainizations
cd ${FAB_PATH}/organizations/peerOrganizations/${ORG}/users
if [ -d "${USER}@${ORG}" ]; then
  echo "remove old crypto ${USER}@${ORG}"
  rm -Rf ${USER}\@${ORG}
fi
cp -R User1\@${ORG} ${USER}\@${ORG}
cd ${USER}\@${ORG}
rm -R msp/keystore
cp -R ${WORK}/${USER}\@${ORG}/msp/keystore msp
rm msp/admincerts/User1\@${ORG}-cert.pem
cp ${WORK}/${USER}\@${ORG}/msp/signcerts/cert.pem msp/admincerts/${USER}\@${ORG}-cert.pem
rm msp/signcerts/User1\@${ORG}-cert.pem
cp ${WORK}/${USER}\@${ORG}/msp/signcerts/cert.pem msp/signcerts/${USER}\@${ORG}-cert.pem
openssl x509 -noout -text -in msp/signcerts/${USER}\@${ORG}-cert.pem
