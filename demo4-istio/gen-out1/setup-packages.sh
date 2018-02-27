#!/usr/bin/env bash

#
# The script to automate deployment of system packages.
#
# During execution it makes an attempt to download packages from specified repo,
# if they do not exist along with the script.
#
# It is assumed that kubectl and helm CLI are installed locally,
# and ~/.kube/config is setup for the target cluster,
# or KUBECONFIG variable points to a config file
#
# @author Serge Belolipetski
#

## Usage: setup-packages.sh
##
# Do not modify content below.

# connect an optional properties file
if [[ -f setup.properties ]]; then
    source setup.properties
fi

# defaults
HELM_REPO_URL="${HELM_REPO_URL:-https://nexus.ecp.eastbanctech.com/repository/helm}"
HELM_REPO_USERNAME="${HELM_REPO_USERNAME:-ecp-build}"
HELM_REPO_PASSWORD="${HELM_REPO_PASSWORD:-}"

#
# Download helm package specified by filename.
#
# Parameter: filename
#
function download_helm_package() {
    CHART_PACKAGE_FILENAME="${1}"
    echo "Downloading ${CHART_PACKAGE_FILENAME}..."
    curl --user "$HELM_REPO_USERNAME:$HELM_REPO_PASSWORD" --progress-bar -f -O "${HELM_REPO_URL}/${CHART_PACKAGE_FILENAME}" || true
}

#
# Check for tiller up and running
#
function wait_tiller_deployed() {
    echo "Checking for tiller..."
    local ATTEMPT=0
    while true ; do
        FOUND_TILLER=$(kubectl get pods --namespace kube-system 2> /dev/null | grep tiller-deploy)
        if [[ "${FOUND_TILLER}" != "" ]] ; then
            if helm version 2>&1 > /dev/null; then
                # tiller ready
                break
            fi
        fi
        printf "."
        sleep 30
        ATTEMPT=$((ATTEMPT + 1))
    done
    echo "Tiller is available"
}


#
# Install helm package specified by release name.
# If the package exists in the target cluster, then it gets upgraded.
#
# Parameter: release name
#
function install_helm_package() {
    RELEASE_NAME="${1}"
    VERSION="${2}"
    CHART_NAME="${RELEASE_NAME}-${VERSION}"
    CHART_PACKAGE_FILENAME="${RELEASE_NAME}-${VERSION}.tgz"
    CUSTOM_PARAMS_HELM_YAML="${RELEASE_NAME}-values.yaml"
    NAMESPACE="${3:-kube-system}"

    if [[ -f "${CHART_PACKAGE_FILENAME}" ]] ; then
        echo "Package ${CHART_PACKAGE_FILENAME} found"
    else
        echo "Package ${CHART_PACKAGE_FILENAME} not found on disk, so need to download"
        download_helm_package ${CHART_PACKAGE_FILENAME}
    fi

    echo "Checking for release of ${RELEASE_NAME}"

    FOUND_RELEASE=$(helm list --all -q | grep -x "${RELEASE_NAME}" || true)

    helm upgrade -i "${RELEASE_NAME}" ${CHART_PACKAGE_FILENAME} -f ${CUSTOM_PARAMS_HELM_YAML} --namespace ${NAMESPACE}
    echo "Status: INSTALLED/UPGRADED"
}

wait_tiller_deployed

echo "Deploying system components and finalizing the setup..."

install_helm_package kublr-system 0.2.3 kube-system
install_helm_package kublr-feature-logging 0.4.3 kube-system
install_helm_package kublr-feature-monitoring 0.4.1 kube-system
install_helm_package kublr-feature-ingress 0.3.1 kube-system
