# Introduction

This is a demo `produce` and `consume` app for `Apache Kafka`. Both the app and Kafka run on containers,
for local dev using `docker-compos`, and deploy to Google Cloud Platform using `Terraform`.

![Screenshot](screenshot.png)

## Local Development

Install `docker-compose` and you're all set.

```bash
# Start kafka and the app containers
$ docker-compose up -d
# Shell into the app container
$ docker-compose exec app bash
# Run the server. It auto reloads on code change
$ ./run.sh
# Call the API endpoints from your host, outside the docker shell
$ curl http://localhost:8080
# consume the messages
$ curl http://localhost:8080/consume/10 -XPOST
# produce 10 messages
$ curl http://localhost:8080/produce/10 -XPOST
# produce 10 messages with a prefix
$ curl http://localhost:8080/produce/10?prefix=GAGA -XPOST
# produce 1_000 messages, by default
$ curl http://localhost:8080/produce -XPOST
```

## Deploy to GCP
```bash
# Build the image
$ docker build . -t <your repo> #//e.g. us-central1-docker.pkg.dev/<your project>/kfk/app
$ docker push <your repo>
# Make changes to the [terraform/main.tf](terraform/main.tf) file to select the appropriate image, project / regions, etc.
$ cd terraform
# will deploy a GCE VM with Kafka and a Cloud Run service
$ terraform apply
# will allow you to access the Cloud Run service locally
$ gcloud run proxy kfk --region us-central-1
# Now you can all the endpoints as your dev environment
$ curl http://localhost:8080/...
```
