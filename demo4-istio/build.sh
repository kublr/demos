#!/bin/sh

cd smackapi/smackapi

GIT_BRANCH=$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)
GIT_COMMIT=$(git rev-parse --short HEAD)
BUILD_DATE=$(date +"%Y-%m-%d %H-%M-%S")
export DOCKER_TAG=${GIT_BRANCH}-${GIT_COMMIT}

echo $DOCKER_TAG



GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o smackapi

docker build --build-arg BUILD_DATE="${BUILD_DATE}" \
             --build-arg IMAGE_TAG_REF=${DOCKER_TAG} \
             --build-arg VCS_REF=${GIT_COMMIT} \
             -t alex202/brigade-smackapi:${DOCKER_TAG} .

docker push alex202/brigade-smackapi:${DOCKER_TAG}

cd ../../

helm upgrade -i --set image.v2.tag=${DOCKER_TAG} smackapi smackapi/charts/smackapi

echo $?
