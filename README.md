# LINUXtips-PICK

## To build a new image based on Dockerfile present in this repository, please use the following commands:

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

## To build image apk based with melange and apko use the steps below:

Make sure the packages/ directory is removed:

```sh
rm -rf ./packages/
```

Downloading the melange image.

```sh
docker pull cgr.dev/chainguard/melange:latest
```

Check that you are able to run melange with ***docker run***.

```sh
docker run --rm cgr.dev/chainguard/melange version
```

Create a temporary melange keypair to sign it.<br>
This will generate a melange.rsa and melange.rsa.pub files in the current directory.

```sh
docker run --rm -v "${PWD}":/work cgr.dev/chainguard/melange keygen
```

Build an apk for all architectures using melange.<br>
When the build is finished, you should be able to find the ***packages*** folder containing the generated apks.

```sh
docker run --privileged --rm -v "${PWD}":/work cgr.dev/chainguard/melange build melange.yaml --arch amd64,aarch64 --signing-key melange.rsa
```

A volume sharing your current folder with the location /work in the apko container, running the apko build command to generate an image based on your apko.yaml definition file.<br>
The command will generate a few new files in the app’s directory:
- giropops-senhas.tar — the packaged OCI image that can be imported with a docker load command
- sbom-%host-architecture%.spdx.json — an SBOM file for your host architecture in spdx-json format

```sh
docker run --rm --workdir /work -v ${PWD}:/work cgr.dev/chainguard/apko build apko.yaml giropops-senhas:1.0 giropops-senhas.tar -k melange.rsa.pub --arch host
```

Load your image within Docker.<br>
Note that the image loaded to docker was **giropops-senhas:1.0-%host-architecture%**. Note that %host-architecture% represents your target architecture

```sh
docker load < giropops-senhas.tar
```

To run the container and validate create a network.<br>
The created network must be informed to redis and application.

```sh
docker network create giropops-senhas
```

Then start the redis container by informing the network

```sh
docker run -d --network giropops-senhas -p 6379:6379 --name redis redis:7.0.14-alpine
```

Start giropops-senhas container by informing the network.<br>
Note that %host-architecture% represents your target architecture.<br>
You can check with the **docker image ls** command the new image created.<br>

Ex.: *docker container run -d -p 5000:5000 --network giropops-senhas --env REDIS_HOST=redis --name giropops-senhas giropops-senhas:1.0-amd64*

```sh
docker container run -d -p 5000:5000 --network giropops-senhas --env REDIS_HOST=redis --name giropops-senhas giropops-senhas:1.0-%host-architecture%
```