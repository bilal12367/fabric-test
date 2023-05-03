export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/../vm1/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_ORG2_CA=${PWD}/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export PEER1_ORG2_CA=${PWD}/crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/../artifacts/channel/config/

export CHANNEL_NAME=mychannel

setGlobalsForPeer0Org2() {
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:8051

}

setGlobalsForPeer1Org2() {
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:8052

}

fetchChannelBlock() {
    rm -rf ./channel-artifacts/*
    setGlobalsForPeer0Org2
    # Replace localhost with your orderer's vm IP address
    peer channel fetch 0 ../vm1/channel-artifacts/$CHANNEL_NAME.block -o localhost:7053 \
        --ordererTLSHostnameOverride orderer.example.com \
        -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
    
    echo "Fetch Channel Completed"
}

# fetchChannelBlock

joinChannel() {
    echo "Join Channel Started"
    setGlobalsForPeer0Org2
    peer channel join -b ../vm1/channel-artifacts/$CHANNEL_NAME.block

    echo "Join Channel 2 Started"
    setGlobalsForPeer1Org2
    peer channel join -b ../vm1/channel-artifacts/$CHANNEL_NAME.block
    echo "Join Channel Completed"
}

# joinChannel

updateAnchorPeers() {
    setGlobalsForPeer0Org2
    # Replace localhost with your orderer's vm IP address

    peer channel update -o localhost:7053 --ordererTLSHostnameOverride orderer.example.com \
        -c $CHANNEL_NAME -f ./../artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

}

# updateAnchorPeers

fetchChannelBlock
joinChannel
updateAnchorPeers