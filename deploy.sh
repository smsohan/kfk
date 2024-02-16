set -x
set -e

# build and push the app image
cd app
IMAGE="us-central1-docker.pkg.dev/sohansm-project/kfk/app"
docker build . -t $IMAGE
NEW_TAG=$(docker push $IMAGE | tail -n1 | awk '{print $3}')
echo $NEW_TAG

# deploy the new image
cd ../terraform
sed -i "s/app@.*$/app@$NEW_TAG\"/" variables.tf
terraform apply --auto-approve

cd ..
set +e