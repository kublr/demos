FROM gcr.io/google_containers/ubuntu-slim:0.12

MAINTAINER Alex Egorov (alex202@egorov.net)

WORKDIR /opt/demo

RUN apt-get update && apt-get install -y ca-certificates

ENTRYPOINT ["/opt/demo/randstr"]
EXPOSE 8080

ADD target/randstr randstr