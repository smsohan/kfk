# build and push the consumer image
CONSUMER_IMAGE="us-central1-docker.pkg.dev/sohansm-project/kfk/consumer"
docker build . -t $CONSUMER_IMAGE
NEW_CONSUMER_IMAGE_TAG=$(docker push $CONSUMER_IMAGE | tail -n1 | awk '{print $3}')
echo $NEW_CONSUMER_IMAGE_TAG

# gcloud alpha run deploy kfk-consumer \
# # --image us-central1-docker.pkg.dev/sohansm-project/kfk/consumer@$NEW_CONSUMER_IMAGE_TAG \
# --no-cpu-throttling \
# --service-min-instances=1 \
# --no-default-url \
# --no-deploy-health-check \
# --region=us-central1 \
# --execution-environment=gen2 \
# --service-account=kfk-service-account@sohansm-project.iam.gserviceaccount.com \
# --cpu=1000m --memory=512Mi \
# --set-env-vars=APP_ENV=production,KAFKA_BOOTSTRAP_SERVERS=10.10.0.2:9094,KAFKA_TOPIC=test-topic,DELAY_IN_SECONDS=0.25 \
# --vpc-egress=private-ranges-only --network=kfk-vpc --subnet=kfk-vpc-subnet
