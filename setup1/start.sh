cd vm1/create-certificate-with-ca

./create-certificate-with-ca.sh

cd ../../vm2/create-certificate-with-ca

./create-certificate-with-ca.sh

cd ../../vm3/create-certificate-with-ca

./create-certificate-with-ca.sh

cd ../../artifacts/channel

./create-artifacts.sh

cd ../../vm1/

docker-compose -f docker-network.yml down

sleep 2

docker-compose -f docker-network.yml up -d

cd ../vm2

sleep 2

docker-compose -f docker-network.yml down

sleep 5

docker-compose -f docker-network.yml up -d

cd ../vm3

sleep 2

docker-compose -f docker-network.yml down

sleep 5

docker-compose -f docker-network.yml up -d

sleep 2

cd ../vm1

./createChannel.sh

cd ../vm2

./joinChannel.sh

cd ../vm3

./joinChannel.sh

cd ../vm1

./deployChaincode.sh start

cd ../vm2

./installAndApprove.sh

cd ../vm3

./installAndApprove.sh

cd ../vm1

./deployChaincode.sh init