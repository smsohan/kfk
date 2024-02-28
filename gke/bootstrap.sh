NAME=kfk
LOCATION=us-central1
IMAGE="us-central1-docker.pkg.dev/sohansm-project/kfk/consumer:latest"
TOPIC=gke-test-topic

# gcloud container clusters create-auto $NAME-cluster \
#     --location=$LOCATION \
#     --network $NAME-vpc \
#     --subnetwork $NAME-vpc-subnet

gcloud container clusters get-credentials $NAME-cluster \
    --location $LOCATION

kubectl apply -f deployment.yml


# /opt/bitnami/kafka/bin/kafka-console-producer.sh --bootstrap-server 127.0.0.1:9092 --producer.config /opt/bitnami/kafka/config/producer.properties --topic gke-test-topic-2
