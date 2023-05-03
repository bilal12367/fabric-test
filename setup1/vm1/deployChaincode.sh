
export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_ORG1_CA=${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/../vm2/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export PEER0_ORG3_CA=${PWD}/../vm3/crypto-config/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/../artifacts/channel/config/


export CHANNEL_NAME=mychannel

setGlobalsForPeer0Org1() {
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer1Org1() {
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7052

}

# setGlobalsForPeer0Org2() {
#     export CORE_PEER_LOCALMSPID="Org2MSP"
#     export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
#     export CORE_PEER_MSPCONFIGPATH=${PWD}/../../artifacts/channel/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
#     export CORE_PEER_ADDRESS=localhost:8050

# }

# setGlobalsForPeer1Org2() {
#     export CORE_PEER_LOCALMSPID="Org2MSP"
#     export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
#     export CORE_PEER_MSPCONFIGPATH=${PWD}/../../artifacts/channel/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
#     export CORE_PEER_ADDRESS=localhost:10051

# }

presetup() {
    echo Vendoring Go dependencies ...
    pushd ./../artifacts/src/github.com/fabcar/go
    # cd ./../artifacts/src/github.com/fabcar/go
    echo $PWD
    # go install
    go mod init fabcar.go
    go mod tidy
    go build
    GO111MODULE=on go mod vendor

    popd
    echo Finished vendoring Go dependencies
}
# presetup

CHANNEL_NAME="mychannel"
CC_RUNTIME_LANGUAGE="golang"
VERSION="1"
CC_SRC_PATH="./../artifacts/src/github.com/fabcar/go"
CC_NAME="fabcar"

packageChaincode() {
    rm -rf ${CC_NAME}.tar.gz
    setGlobalsForPeer0Org1
    peer lifecycle chaincode package ${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC_NAME}_${VERSION}
    echo "===================== Chaincode is packaged on peer0.org1 ===================== "
}
# packageChaincode

installChaincode() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.org1 ===================== "

}

# installChaincode

queryInstalled() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer0.org1 on channel ===================== "
}

# queryInstalled

approveForMyOrg1() {
    setGlobalsForPeer0Org1
    # set -x
    # Replace localhost with your orderer's vm IP address
    peer lifecycle chaincode approveformyorg -o localhost:7053 \
        --ordererTLSHostnameOverride orderer.example.com --tls \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}
    # set +x

    echo "===================== chaincode approved from org 1 ===================== "

}

# queryInstalled
# approveForMyOrg1

checkCommitReadyness() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from org 1 ===================== "
}

# checkCommitReadyness

commitChaincodeDefination() {
    echo commit Chaincode Definition started
    setGlobalsForPeer0Org1
    peer lifecycle chaincode commit -o localhost:7053 --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
        --peerAddresses localhost:8051 --tlsRootCertFiles $PEER0_ORG2_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG3_CA \
        --version ${VERSION} --sequence ${VERSION} --init-required
    echo commit Chaincode Definition successful
}

# commitChaincodeDefination

queryCommitted() {
    echo Query Commited started
    setGlobalsForPeer0Org1
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}
    echo Query Commited successful
}

# queryCommitted

chaincodeInvokeInit() {
    echo Chaincode invokd init started
    setGlobalsForPeer0Org1
    peer chaincode invoke -o localhost:7053 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:8051 --tlsRootCertFiles $PEER0_ORG2_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG3_CA \
        --isInit -c '{"Args":[]}'
        # --peerAddresses localhost:7050 --tlsRootCertFiles $PEER0_ORG1_CA \

    echo Chaincode invokd init successful
    ## Init ledger
    # peer chaincode invoke -o localhost:9050 \
    #     --ordererTLSHostnameOverride orderer.example.com \
    #     --tls $CORE_PEER_TLS_ENABLED \
    #     --cafile $ORDERER_CA \
    #     -C $CHANNEL_NAME -n ${CC_NAME} \
    #     --peerAddresses localhost:8050 --tlsRootCertFiles $PEER0_ORG1_CA \
    #     --peerAddresses localhost:9056 --tlsRootCertFiles $PEER0_ORG2_CA \
    #     -c '{"function": "initLedger","Args":[]}'
}

 # --peerAddresses localhost:7050 --tlsRootCertFiles $PEER0_ORG1_CA \

# chaincodeInvokeInit

chaincodeInvoke() {
    echo chaincode invoked started
    setGlobalsForPeer0Org1

    ## Create Car
    # peer chaincode invoke -o localhost:9050 \
    #     --ordererTLSHostnameOverride orderer.example.com \
    #     --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
    #     -C $CHANNEL_NAME -n ${CC_NAME} \
    #     --peerAddresses localhost:7050 --tlsRootCertFiles $PEER0_ORG1_CA \
    #     --peerAddresses localhost:8050 --tlsRootCertFiles $PEER0_ORG2_CA   \
    #     --peerAddresses localhost:9056 --tlsRootCertFiles $PEER0_ORG3_CA \
    #     -c '{"function": "createCar","Args":["Car-ABCDEEE", "Audi", "R8", "Red", "Sandip"]}'

    ## Init ledger
    peer chaincode invoke -o localhost:7053 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
        --peerAddresses localhost:8051 --tlsRootCertFiles $PEER0_ORG2_CA \
        -c '{"function": "initLedger","Args":[]}'
        # --peerAddresses localhost:9056 --tlsRootCertFiles $PEER0_ORG3_CA \

    echo chaincode invoked successful
}

# chaincodeInvoke

chaincodeQuery() {
    setGlobalsForPeer0Org1

    # Query Car by Id
    peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function": "queryCar","Args":["CAR0"]}'
 
}

# chaincodeQuery

# Run this function if you add any new dependency in chaincode
input=$(printf "%s" $1)

if [ $1 = 'start' ];
then
    presetup

    packageChaincode
    installChaincode
    queryInstalled
    approveForMyOrg1
    checkCommitReadyness
else 
    commitChaincodeDefination
    queryCommitted
    chaincodeInvokeInit
    sleep 5
    chaincodeInvoke
    sleep 3
    chaincodeQuery
fi

# if[ $1 = 'start']  then
#     presetup

#     packageChaincode
#     installChaincode
#     queryInstalled
#     approveForMyOrg1
#     checkCommitReadyness
# elif[ $1 = 'init'] 
# then
#     commitChaincodeDefination
#     queryCommitted
#     chaincodeInvokeInit
#     sleep 5
#     chaincodeInvoke
#     sleep 3
#     chaincodeQuery
# fi