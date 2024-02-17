set -x
set -e

# build and push the app image
cd app
IMAGE="us-central1-docker.pkg.dev/sohansm-project/kfk/app"
docker build . -t $IMAGE
NEW_APP_IMAGE_TAG=$(docker push $IMAGE | tail -n1 | awk '{print $3}')
echo $NEW_APP_IMAGE_TAG
cd ..

# build and push the consumer image
cd consumer
CONSUMER_IMAGE="us-central1-docker.pkg.dev/sohansm-project/kfk/consumer"
docker build . -t $CONSUMER_IMAGE
NEW_CONSUMER_IMAGE_TAG=$(docker push $CONSUMER_IMAGE | tail -n1 | awk '{print $3}')
echo $NEW_CONSUMER_IMAGE_TAG


# deploy the new image
cd ../terraform
sed -i "s/app@.*$/app@$NEW_APP_IMAGE_TAG\"/" variables.tf
sed -i "s/consumer@.*$/consumer@$NEW_CONSUMER_IMAGE_TAG\"/" variables.tf
terraform apply --auto-approve

cd ..
set +e