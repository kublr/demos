#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# this script is expected to be located in the same directory as the directory containing chart files
readonly ROOT="$(dirname "$(readlink -f "${BASH_SOURCE}")")"

# It is expected that CHART_NAME and CHART_VERSION variables are loaded from main.properties file
source "${ROOT}"/main.properties

# Build procedure may also set CHART_PUBLISH_VERSION variable, which will be used as a version for the chart
CHART_PUBLISH_VERSION="${CHART_PUBLISH_VERSION:-"${CHART_VERSION}"}"

# Target package name
PACKAGE_NAME="${CHART_NAME}-${CHART_PUBLISH_VERSION}.tgz"

# if 'build' parameter is specified, do build
DO_BUILD=""
if [[ " $* " =~ ' build ' ]]; then
    DO_BUILD=yes
fi
# if 'publish' parameter is specified, do publish
DO_PUBLISH=""
if [[ " $* " =~ ' publish ' ]]; then
    DO_PUBLISH=yes
fi


# if 'docker' parameter is specified, do publish
DO_DOCKER=""
if [[ " $* " =~ ' docker ' ]]; then
    DO_DOCKER=yes
fi


# if neither is specified, print usage
if [[ -z "${DO_BUILD}${DO_PUBLISH}${DO_DOCKER}" ]]; then
    echo
    echo "Usage: ./build.sh [build] [docker] [publish]"
    echo
    echo "  Build will use version from main.properties by default, but this may be overridden via CHART_PUBLISH_VERSION environment variable."
    echo
    echo "  Publish will use environment variables HELM_TARGET_REPO, HELM_TARGET_REPO_USER, HELM_TARGET_REPO_PASSWORD to publish helm chart to the specified Helm repository."
    exit
fi

function helm::process_file(){
    FILE="${1}"
    SED_INPLACE='-i'
    if [ "$(uname)" == 'Darwin' ] ; then
        SED_INPLACE='-i.tmp'
    fi
    sed ${SED_INPLACE} \
            -e "s/{{CHART_PUBLISH_VERSION}}/${CHART_PUBLISH_VERSION}/g" \
            -e "s/{{DOCKER_REPO_URL}}/${DOCKER_REPO_URL}/g" \
        "${FILE}"
}

# build chart package
if [[ -n "${DO_BUILD}" ]]; then
    echo Building

    # init helm; helm init may be run multiple times
    helm init --client-only > /dev/null

    # Target directory is used to build the chart package
    mkdir -p "${ROOT}"/target

    # backup pre-build Chart.yaml file
    cp "${ROOT}/${CHART_NAME}"/Chart.yaml "${ROOT}/target/Chart.yaml.version-backup"
    cp "${ROOT}/${CHART_NAME}"/values.yaml "${ROOT}/target/values.yaml.version-backup"

    # Version in Chart.yaml file is ignored, CHART_PUBLISH_VERSION is used instead
    sed -i -e 's/^version:.*$/version: '"${CHART_PUBLISH_VERSION}"'/g' "${ROOT}/${CHART_NAME}"/Chart.yaml
    helm::process_file "${ROOT}/${CHART_NAME}"/values.yaml

    # Check chart with helm lint
    helm lint "${ROOT}/${CHART_NAME}"

    # Build helm package
    (
    cd "${ROOT}/${CHART_NAME}"
    helm dependency build

    cd "${ROOT}"/target
    helm package "../${CHART_NAME}"
    )

    # restore pre-build Chart.yaml file
    mv "${ROOT}/target/Chart.yaml.version-backup" "${ROOT}/${CHART_NAME}"/Chart.yaml
    mv "${ROOT}/target/values.yaml.version-backup" "${ROOT}/${CHART_NAME}"/values.yaml
fi

if [[ -n "${DO_DOCKER}" ]]; then
    echo
    echo
    echo building go executable and docker image ...
    echo
    go build -o target/randstr
    DOCKER_REPO_URL="${DOCKER_REPO_URL:=docker.ecp.eastbanctech.com}"
    docker build -t ${DOCKER_REPO_URL}/${CHART_NAME}:${CHART_PUBLISH_VERSION} .
    docker push ${DOCKER_REPO_URL}/${CHART_NAME}:${CHART_PUBLISH_VERSION}
fi

# publish chart package
if [[ -n "${DO_PUBLISH}" ]]; then
    echo Publishing

    HELM_TARGET_REPO="${HELM_TARGET_REPO:-"https://nexus.ecp.eastbanctech.com/repository/helm"}"
    HELM_TARGET_REPO_USER="${HELM_TARGET_REPO_USER:-}"
    HELM_TARGET_REPO_PASSWORD="${HELM_TARGET_REPO_PASSWORD:-}"

    CURL_AUTH_OPTS="${HELM_TARGET_REPO_USER:+"--user "${HELM_TARGET_REPO_USER}:${HELM_TARGET_REPO_PASSWORD}""}"

    # Upload helm package to a repository
    curl -X PUT -f --progress-bar ${CURL_AUTH_OPTS} --upload-file "${ROOT}/target/${PACKAGE_NAME}" "${HELM_TARGET_REPO}/${PACKAGE_NAME}"
fi
