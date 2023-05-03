

init() {
    cd ..
    
    docker-compose down
    
    sudo rm -r fabric-ca/
    
    docker-compose up -d
    
    sudo rm -r crypto-config
    
}

createCertificateForOrderers(){
    sleep 2
    
    echo '=================Starting To Create Certificates for orderer================='
    
    sudo mkdir -p crypto-config/peerOrganizations/org1.example.com/
    
    export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config/ordererOrganizations/org1.example.com/
    
    fabric-ca-client enroll -u https://admin:adminpw@localhost:7056 --caname ca-orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
    
       
    echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7056-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7056-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7056-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7056-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/crypto-config/ordererOrganizations/org1.example.com/msp/config.yaml
    
    echo
    echo "Registering orderer"
    echo
    
    fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
    
    echo
    echo "Registering orderer2"
    echo
    
    fabric-ca-client register --caname ca-orderer --id.name orderer2 --id.secret orderer2pw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
    
    echo
    echo "Registering orderer3"
    echo
    
    fabric-ca-client register --caname ca-orderer --id.name orderer3 --id.secret orderer3pw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
    
    echo
    echo "Register the orderer admin"
    echo
    
    fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
    
    # ---------------------------------------------------------------------------
    #  Orderer1
    
    mkdir -p ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer.example.com
    
    echo
    echo "## Generate the orderer msp"
    echo
    
    fabric-ca-client enroll -u https://orderer:ordererpw@localhost:7056 --caname ca-orderer -M ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer.example.com/msp --csr.hosts orderer.example.com --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
    # fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9055 --caname ca-orderer -M ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
    
    cp ${PWD}/crypto-config/ordererOrganizations/org1.example.com/msp/config.yaml ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer.example.com/msp/config.yaml
    
    echo
    echo "## Generate the orderer tls"
    echo
    
    fabric-ca-client enroll -u https://orderer:ordererpw@localhost:7056 --caname ca-orderer -M ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer.example.com/tls --enrollment.profile tls --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
    
    cp ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer.example.com/tls/ca.crt
    cp ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer.example.com/tls/signcerts/* ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer.example.com/tls/server.crt
    cp ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer.example.com/tls/keystore/* ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer.example.com/tls/server.key
    
    mkdir ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer.example.com/msp/tlscacerts
    cp ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    
    mkdir ${PWD}/crypto-config/ordererOrganizations/org1.example.com/msp/tlscacerts
    cp ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/crypto-config/ordererOrganizations/org1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    
    # ---------------------------------------------------------------------------
    #  Orderer2
    
    mkdir -p ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer2.example.com
    
    echo
    echo "## Generate the orderer2 msp"
    echo
    
    fabric-ca-client enroll -u https://orderer2:orderer2pw@localhost:7056 --caname ca-orderer -M ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer2.example.com/msp --csr.hosts orderer2.example.com --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
    
    cp ${PWD}/crypto-config/ordererOrganizations/org1.example.com/msp/config.yaml ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer2.example.com/msp/config.yaml
    
    echo
    echo "## Generate the orderer2 tls"
    echo
    
    fabric-ca-client enroll -u https://orderer2:orderer2pw@localhost:7056 --caname ca-orderer -M ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer2.example.com/tls --enrollment.profile tls --csr.hosts orderer2.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
    
    cp ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer2.example.com/tls/tlscacerts/* ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer2.example.com/tls/ca.crt
    cp ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer2.example.com/tls/signcerts/* ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer2.example.com/tls/server.crt
    cp ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer2.example.com/tls/keystore/* ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer2.example.com/tls/server.key
    
    mkdir ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer2.example.com/msp/tlscacerts
    cp ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer2.example.com/tls/tlscacerts/* ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer2.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    # ---------------------------------------------------------------------------
    #  Orderer3
    
    mkdir -p ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer3.example.com
    
    echo
    echo "## Generate the orderer 3 msp"
    echo
    
    fabric-ca-client enroll -u https://orderer3:orderer3pw@localhost:7056 --caname ca-orderer -M ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer3.example.com/msp --csr.hosts orderer3.example.com --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
    
    cp ${PWD}/crypto-config/ordererOrganizations/org1.example.com/msp/config.yaml ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer3.example.com/msp/config.yaml
    
    echo
    echo "## Generate the orderer3 tls"
    echo
    
    fabric-ca-client enroll -u https://orderer3:orderer3pw@localhost:7056 --caname ca-orderer -M ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer3.example.com/tls --enrollment.profile tls --csr.hosts orderer3.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
    
    cp ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer3.example.com/tls/tlscacerts/* ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer3.example.com/tls/ca.crt
    cp ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer3.example.com/tls/signcerts/* ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer3.example.com/tls/server.crt
    cp ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer3.example.com/tls/keystore/* ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer3.example.com/tls/server.key
    
    mkdir ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer3.example.com/msp/tlscacerts
    cp ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer3.example.com/tls/tlscacerts/* ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer3.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    
    mkdir -p ${PWD}/crypto-config/ordererOrganizations/org1.example.com/users/Admin@example.com
    
    echo
    echo "## Generate the admin msp"
    echo
    
    fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:7056 --caname ca-orderer -M ${PWD}/crypto-config/ordererOrganizations/org1.example.com/users/Admin@example.com/msp --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
    
    cp ${PWD}/crypto-config/ordererOrganizations/org1.example.com/msp/config.yaml ${PWD}/crypto-config/ordererOrganizations/org1.example.com/users/Admin@example.com/msp/config.yaml
    
}

createCertificateForOrg1() {
    sleep 2
    
    echo '=================Starting To Create Certificates for org1================='
    
    sudo mkdir -p crypto-config/peerOrganizations/org1.example.com/
    
    export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config/peerOrganizations/org1.example.com/
    
    fabric-ca-client enroll -u https://admin:adminpw@localhost:7050 --caname ca.org1.example.com --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem
    
    echo 'NodeOUs:
    Enable: true
    ClientOUIdentifier:
        Certificate: cacerts/localhost-7050-ca-org1-example-com.pem
        OrganizationalUnitIdentifier: client
    PeerOUIdentifier:
        Certificate: cacerts/localhost-7050-ca-org1-example-com.pem
        OrganizationalUnitIdentifier: peer
    AdminOUIdentifier:
        Certificate: cacerts/localhost-7050-ca-org1-example-com.pem
        OrganizationalUnitIdentifier: admin
    OrdererOUIdentifier:
        Certificate: cacerts/localhost-7050-ca-org1-example-com.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/crypto-config/peerOrganizations/org1.example.com/msp/config.yaml
    
    
    echo
    echo "Registering peer0"
    echo
    
    fabric-ca-client register --caname ca.org1.example.com --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem
    echo
    echo "Registering peer1"
    echo
    
    fabric-ca-client register --caname ca.org1.example.com --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem
    
    # echo
    # echo "Registering Orderer 1"
    # echo
    
    # fabric-ca-client register --caname ca.org1.example.com --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem
    
    echo
    echo "Registering user"
    echo
    
    fabric-ca-client register --caname ca.org1.example.com --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem
    echo
    echo "Registering admin"
    echo
    
    fabric-ca-client register --caname ca.org1.example.com --id.name org1admin --id.secret org1adminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem
    
    
    mkdir -p ${PWD}/crypto-config/peerOrganizations/org1.example.com/peers
    
    # ---------------------------------------------------------------------------------------------------------------------------------------
    # Peer 0
    echo
    echo "Generating Peer0 msp"
    echo
    
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7050 --caname ca.org1.example.com -M ${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp --csr.hosts peer0.org1.example.com --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem
    
    cp ${PWD}/crypto-config/peerOrganizations/org1.example.com/msp/config.yaml ${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/config.yaml
    
    echo
    echo "Generating peer0 tls"
    echo
    
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7050 --caname ca.org1.example.com -M ${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls --enrollment.profile tls --csr.hosts peer0.org1.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem
    
    cp ${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/tlscacerts/* ${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    cp ${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/signcerts/* ${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
    cp ${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/keystore/* ${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
    # cp ${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/tlscacerts/* ${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    # cp ${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/signcerts/* ${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
    # cp ${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/keystore/* ${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
    
    mkdir ${PWD}/crypto-config/peerOrganizations/org1.example.com/msp/tlscacerts
    cp ${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/tlscacerts/* ${PWD}/crypto-config/peerOrganizations/org1.example.com/msp/tlscacerts/ca.crt
    
    mkdir ${PWD}/crypto-config/peerOrganizations/org1.example.com/tlsca
    cp ${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/tlscacerts/* ${PWD}/crypto-config/peerOrganizations/org1.example.com/tlsca/tlsca.org1.example.com-cert.pem
    
    mkdir ${PWD}/crypto-config/peerOrganizations/org1.example.com/ca
    cp ${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/cacerts/* ${PWD}/crypto-config/peerOrganizations/org1.example.com/ca/ca.org1.example.com-cert.pem
    
    # ---------------------------------------------------------------------------------------------------------------------------------------
    # Peer 1
    
    mkdir -p ${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com
    
    echo
    echo "Generating Peer1 msp"
    echo
    
    fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7050 --caname ca.org1.example.com -M ${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/msp --csr.hosts peer1.org1.example.com --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem
    
    cp ${PWD}/crypto-config/peerOrganizations/org1.example.com/msp/config.yaml ${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/msp/config.yaml
    
    echo
    echo "Generating Peer1 tls"
    echo
    
    fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7050 --caname ca.org1.example.com -M ${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls --enrollment.profile tls --csr.hosts peer1.org1.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem
    
    cp ${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/tlscacerts/* ${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt
    cp ${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/signcerts/* ${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/server.crt
    cp ${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/keystore/* ${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/server.key
    
    # ---------------------------------------------------------------------------------------------------------------------------------------
    # Orderer 1
    # mkdir -p ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer.example.com
    
    # echo
    # echo "Generating Orderer1 msp"
    # echo
    
    # fabric-ca-client enroll -u https://orderer:ordererpw@localhost:7050 --caname ca.org1.example.com -M ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer.example.com/msp --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem
    
    # cp ${PWD}/crypto-config/peerOrganizations/org1.example.com/msp/config.yaml ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer.example.com/msp/config.yaml
    
    # echo
    # echo "Generating Orderer1 tls"
    # echo
    
    # fabric-ca-client enroll -u https://orderer:ordererpw@localhost:7050 --caname ca.org1.example.com -M ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer.example.com/tls --enrollment.profile tls --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem
    
    # cp ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer.example.com/tls/ca.crt
    # cp ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer.example.com/tls/signcerts/* ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer.example.com/tls/server.crt
    # cp ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer.example.com/tls/keystore/* ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer.example.com/tls/server.key
    
    # mkdir -p ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer.example.com/msp/tlscacerts/
    # cp ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer.example.com/tls/tlscacerts/*  ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    
    # mkdir -p ${PWD}/crypto-config/ordererOrganizations/org1.example.com/msp/tlscacerts
    # cp ${PWD}/crypto-config/ordererOrganizations/org1.example.com/orderers/orderer.example.com/tls/tlscacerts/*  ${PWD}/crypto-config/ordererOrganizations/org1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    
    # ---------------------------------------------------------------------------------------------------------------------------------------
    # User And Admin
    
    mkdir -p ${PWD}/crypto-config/peerOrganizations/org1.example.com/users
    
    echo
    echo "Generating User msp"
    echo
    
    fabric-ca-client enroll -u https://user1:user1pw@localhost:7050 --caname ca.org1.example.com -M ${PWD}/crypto-config/peerOrganizations/org1.example.com/users/user1@org1.example.com/msp --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem
    
    echo
    echo "Generating Admin msp"
    echo
    
    fabric-ca-client enroll -u https://org1admin:org1adminpw@localhost:7050 --caname ca.org1.example.com -M ${PWD}/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem
    
    cp ${PWD}/crypto-config/peerOrganizations/org1.example.com/msp/config.yaml ${PWD}/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/config.yaml
}


init

createCertificateForOrg1

createCertificateForOrderers