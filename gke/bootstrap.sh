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

kubectl apply --server-side -f https://github.com/kedacore/keda/releases/download/v2.13.0/keda-2.13.0.yaml


kubectl apply -f app-deployment.yml
kubectl apply -f consumer-deployment.yml

kubectl port-forward <app-pod-id> 8080:8080

# /opt/bitnami/kafka/bin/kafka-console-producer.sh --bootstrap-server 127.0.0.1:9092 --producer.config /opt/bitnami/kafka/config/producer.properties --topic gke-test-topic-2
