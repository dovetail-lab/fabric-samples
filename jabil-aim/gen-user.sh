#!/bin/bash
# generate user key and cert with attribute entity, alias, and email
# usage: gen-user.sh name org
#  e.g., gen-user.sh s1User@s1.com 1

FAB_HOME=${1:-"${PWD}/../../hyperledger/fabric-samples"}
FAB_PATH=${FAB_HOME}/test-network

USER=${2:-"Alice@org1.example.com"}
ALIAS="${USER%%@*}"
DOMAIN="${USER##*@}"
ENTITY="${DOMAIN%%.*}"

ORG_NAME=org1
PORT=7054
if [ "$3" == "2" ]; then
  ORG_NAME=org2
  PORT=8054
fi
ORG=${ORG_NAME}.example.com
CANAME=ca-${ORG_NAME}
TLSCA=${FAB_PATH}/organizations/fabric-ca/${ORG_NAME}/tls-cert.pem

WORK=/tmp/ca
echo "generate key and cert for user ${ALIAS}@${ORG}"

if [ -d "${WORK}" ]; then
  echo "cleanup ${WORK}"
  rm -R "${WORK}"
fi

# check CA server
docker ps | grep "hyperledger/fabric-ca" | grep "${PORT}->${PORT}/tcp"
if [ "$?" -ne 0 ]; then
  echo "CA server is not running.  Start first network with '-a' option, e.g., './byfn.sh up -a -s couchdb'."
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
${FAB_HOME}/bin/fabric-ca-client register --caname ${CANAME} --tls.certfiles ${TLSCA} --id.name ''"${ALIAS}@${ORG}"'' --id.secret ${ALIAS}pw --id.type client --id.attrs 'alias='"${ALIAS}"',entity='"${ENTITY}"',email='"${USER}"''
export FABRIC_CA_CLIENT_HOME=${WORK}/${ALIAS}\@${ORG}
${FAB_HOME}/bin/fabric-ca-client enroll -u https://${ALIAS}@${ORG}:${ALIAS}pw@localhost:${PORT} --caname ${CANAME} --tls.certfiles ${TLSCA} --enrollment.attrs "alias,entity,email" -M ${FABRIC_CA_CLIENT_HOME}/msp
openssl x509 -noout -text -in ${WORK}/${ALIAS}\@${ORG}/msp/signcerts/cert.pem

# copy key and cert to first-network sample crypto-config
cd ${FAB_PATH}/organizations/peerOrganizations/${ORG}/users
if [ -d "${ALIAS}@${ORG}" ]; then
  echo "remove old crypto ${ALIAS}@${ORG}"
  rm -Rf ${ALIAS}\@${ORG}
fi
cp -R User1\@${ORG} ${ALIAS}\@${ORG}
cd ${ALIAS}\@${ORG}
rm -R msp/keystore
cp -R ${WORK}/${ALIAS}\@${ORG}/msp/keystore msp
rm msp/admincerts/User1\@${ORG}-cert.pem
cp ${WORK}/${ALIAS}\@${ORG}/msp/signcerts/cert.pem msp/admincerts/${ALIAS}\@${ORG}-cert.pem
rm msp/signcerts/User1\@${ORG}-cert.pem
cp ${WORK}/${ALIAS}\@${ORG}/msp/signcerts/cert.pem msp/signcerts/${ALIAS}\@${ORG}-cert.pem
openssl x509 -noout -text -in msp/signcerts/${ALIAS}\@${ORG}-cert.pem
