# LINUXtips-PICK

To build a new image please use the command below:

```sh
docker image build -t mirjahal/giropops-senhas:1.0 .
```

Create a network

```sh
docker network create giropops-senhas
```

Start redis container

```sh
docker run -d --network giropops-senhas -p 6379:6379 --name redis redis:7.0.14-alpine
```

Start giropops-senhas container

```sh
docker container run -d -p 5000:5000 --network giropops-senhas --env REDIS_HOST=redis --name giropops-senhas mirjahal/giropops-senhas:1.0
```