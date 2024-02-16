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
# produce 1_000 messages, by default
$ curl http://localhost:8080/produce -XPOST
```