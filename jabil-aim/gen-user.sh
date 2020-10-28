#!/bin/bash
# generate user key and cert with attribute entity, alias, and email
# usage: gen-user.sh name org
#  e.g., gen-user.sh s1User@s1.com 1

FAB_HOME=${1:-"${HOME}/work/fabric-samples"}
USER=${2:-"Alice@org1.example.com"}
ORG=org1.example.com
PORT=7054
ALIAS="${USER%%@*}"
DOMAIN="${USER##*@}"
ENTITY="${DOMAIN%%.*}"

if [ "$3" == "2" ]; then
  ORG=org2.example.com
  PORT=8054
fi

FABRIC_SAMPLE_PATH=${FAB_HOME}/first-network
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
which fabric-ca-client
if [ "$?" -ne 0 ]; then
  echo "fabric-ca-client not found. You can install fabric-ca by using 'go get -u github.com/hyperledger/fabric-ca/cmd/...'"
  exit 1
fi

# enroll CA admin
export FABRIC_CA_CLIENT_HOME=${WORK}/admin
fabric-ca-client getcainfo -u http://localhost:${PORT}
openssl x509 -noout -text -in ${FABRIC_CA_CLIENT_HOME}/msp/cacerts/localhost-${PORT}.pem
fabric-ca-client enroll -u http://admin:adminpw@localhost:${PORT}

# register and enroll new user
# Note: important to make id.name as user@org for signature verification!
fabric-ca-client register --id.name ''"${ALIAS}@${ORG}"'' --id.secret ${ALIAS}pw --id.type client --id.attrs 'alias='"${ALIAS}"',entity='"${ENTITY}"',email='"${USER}"''
export FABRIC_CA_CLIENT_HOME=${WORK}/${ALIAS}\@${ORG}
fabric-ca-client enroll -u http://${ALIAS}@${ORG}:${ALIAS}pw@localhost:${PORT} --enrollment.attrs "alias,entity,email" -M ${FABRIC_CA_CLIENT_HOME}/msp
openssl x509 -noout -text -in ${WORK}/${ALIAS}\@${ORG}/msp/signcerts/cert.pem

# copy key and cert to first-network sample crypto-config
cd ${FABRIC_SAMPLE_PATH}/crypto-config/peerOrganizations/${ORG}/users
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
