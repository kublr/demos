#!/usr/bin/env bash

#
# The script to automate stack creation and cluster configuration.
#
# Execution of this script takes a few minutes to complete,
# as that obviously calls AWS to create a new stack,
# and then awaits for Kubernetes spinning up.
# Once the cluster is up and running, the script will finalize configuration
# with deploying additional system components in Kubernetes cluster.
#
# Portions of this script rely on PyYAML library, install it using pip:
# $ pip install PyYAML
#
# @author Serge Belolipetski
#

## Usage: create-stack.sh

# Do not modify content below.

STACK_NAME='aegorov-istio-aws1'
CLUSTER_NAME='aegorov-istio'
LOCATION_NAME='aws1'

echo "Creating location '${LOCATION_NAME}' of Kublr Kubernetes cluster '${CLUSTER_NAME}'"
echo "Using stack name: ${STACK_NAME}"

export AWS_DEFAULT_REGION="us-west-1"
export AWS_REGION="us-west-1"
export AWS_ACCESS_KEY_ID="AKIAIDNGPS6FEX7VDJBA"
export AWS_SECRET_ACCESS_KEY="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"

#
# Initiate a process of AWS stack creation
#
# Parameter: name of a stack
#
function launch_stack_creation() {
    STACK_NAME="${1}"
    TEMPLATE_FILENAME="file://aws-aegorov-istio-aws1.template"

    if ! aws cloudformation validate-template \
            --region us-west-1 \
            --template-body "${TEMPLATE_FILENAME}"; then
        echo "Template file is invalid or missing"
        exit 1
    fi

    if ! aws cloudformation describe-stacks \
            --region us-west-1 \
            --stack-name "${STACK_NAME}" \
            2>/dev/null 1>/dev/null; then

        aws cloudformation create-stack --stack-name "${STACK_NAME}" \
            --region us-west-1 \
            --on-failure DO_NOTHING \
            --template-body "${TEMPLATE_FILENAME}" \
            --capabilities CAPABILITY_NAMED_IAM \
            --timeout-in-minutes 20 \
            --parameters "[
                    {\"ParameterKey\" : \"KeyName\", \"ParameterValue\" : \"\"},
                    {\"ParameterKey\" : \"KubernetesCluster\", \"ParameterValue\" : \"aegorov-istio\"}
                ]" \
            --tags "[
                    {\"Key\" : \"KubernetesCluster\", \"Value\" : \"aegorov-istio\"}
                ]"
        if [[ "$?" == "0" ]] ; then
            echo "Stack ${STACK_NAME} is being created."
        else
            exit 1
        fi
    else
        echo "Stack ${STACK_NAME} exists, updating."

        CHANGE_SET_NAME=cs-$(date +%F-%H-%M-%S-%Z)
        aws cloudformation \
            delete-change-set \
            --stack-name "${STACK_NAME}" \
            --change-set-name "${CHANGE_SET_NAME}" 2>/dev/null || true

        aws cloudformation \
            create-change-set \
            --stack-name "${STACK_NAME}" \
            --change-set-name "${CHANGE_SET_NAME}" \
            --template-body "${TEMPLATE_FILENAME}" \
            --no-use-previous-template \
            --capabilities CAPABILITY_NAMED_IAM \
            --change-set-type UPDATE \
            --description "Kublr script change set ${CHANGE_SET_NAME}" \
            --parameters "[
                    {\"ParameterKey\" : \"KeyName\", \"ParameterValue\" : \"\"},
                    {\"ParameterKey\" : \"KubernetesCluster\", \"ParameterValue\" : \"aegorov-istio\"}
                ]" \
            --tags "[
                    {\"Key\" : \"KubernetesCluster\", \"Value\" : \"aegorov-istio\"}
                ]"

        echo "Change set ${CHANGE_SET_NAME} creation initiated."

        local ATTEMPT=12
        while true; do
            CS_STATUS=$(aws cloudformation describe-change-set \
                --stack-name "${STACK_NAME}" \
                --change-set-name "${CHANGE_SET_NAME}" \
                --output text --query 'Status' 2>/dev/null)
            if [[ "${CS_STATUS}" == CREATE_COMPLETE ]]; then
                break
            fi

            sleep 5

            ATTEMPT=$((ATTEMPT - 1))
            if [[ "${ATTEMPT}" == "0" ]] ; then
                echo "It takes too long to create a change set for the stack ${STACK_NAME}, interrupting."
                echo "Please, use AWS console to check if anything's wrong with the process."
                exit 1
            fi
        done

        echo "A change set is created for the stack ${STACK_NAME}."

        aws cloudformation describe-change-set \
                --stack-name "${STACK_NAME}" \
                --change-set-name "${CHANGE_SET_NAME}" \
                --output json

        echo "Please review changes."
        read -p "Proceed with update [y/n]? " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]
        then
            echo "Update interrupted."
            exit 1
        fi

        aws cloudformation execute-change-set \
                --stack-name "${STACK_NAME}" \
                --change-set-name "${CHANGE_SET_NAME}"
    fi
}

#
# Wait for the stack create completion.
# It may fail if stack is already created, or something goes wrong under the hood.
# If stack is not created within one hour, it will also fail and interrupt script execution.
#
# Parameter: name of a stack
#
function wait_stack_create_complete() {
    # AWS CLI "cloudformation wait" thing doesn't work on my machine:
    # $ aws cloudformation wait stack-create-complete --stack-name "${STACK_NAME}"
    #
    # AWS CLI details: aws-cli/1.10.1 Python/3.5.2 Linux/4.4.0-62-generic botocore/1.3.23
    #
    # so, implementing it differently by analyzing the status, besides it is much more reliable
    # than cloudformation wait stack-create-complete, as the latter may get stuck on errors

    STACK_NAME="${1}"
    local ATTEMPT=120

    echo "Waiting for stack ${STACK_NAME} to be created/update..."
    while true ; do
        ATTEMPT=$((ATTEMPT - 1))
        if [[ "${ATTEMPT}" == "0" ]] ; then
            echo "It takes too long to create the stack ${STACK_NAME}, interrupting. \nPlease, use AWS console to check if anything's wrong with the process."
            exit 1
        fi
        STACK_STATUS=$(aws cloudformation describe-stacks --stack-name "${STACK_NAME}" --output json | jq -r .Stacks[0].StackStatus)
        case "${STACK_STATUS}" in
            "CREATE_COMPLETE"*)
            echo "${STACK_NAME} has been created"
            break ;;

            "UPDATE_COMPLETE"*)
            echo "${STACK_NAME} has been updated"
            break ;;

            "CREATE_ROLLBACK_COMPLETE"*|"UPDATE_ROLLBACK_COMPLETE"*)
            echo "${STACK_NAME} has been rolled back: ${STACK_STATUS}"
            exit 1 ;;

            "CREATE_FAILED"*|"UPDATE_FAILED"*|"DELETE_FAILED"*)
            echo "Operation on ${STACK_NAME} has failed: ${STACK_STATUS}"
            exit 1 ;;

            "DELETE_IN_PROGRESS"*)
            echo "Stack ${STACK_NAME} is being deleted, cannot proceed further"
            exit 1 ;;

            *)
            printf "."
            sleep 30
            ;;
        esac
    done
}

#
# Download Kubernetes config file from secret bucket,
# which name is obviously computed once the stack is installed.
# If config cannot be downloaded within one hour, it will fail and interrupt script execution.
#
# Parameter: name of a stack
#
function download_config_file() {
    STACK_NAME="${1}"
    local ATTEMPT=120

    echo "Attempting to download config file for Kubernetes cluster installed at ${STACK_NAME}..."
    while true ; do
        ATTEMPT=$((ATTEMPT - 1))
        if [[ "${ATTEMPT}" == "0" ]] ; then
            echo "It takes too long to create the stack ${STACK_NAME}, interrupting. \nPlease, use AWS console to check if anything's wrong with the process."
            exit 1
        fi
        K8S_SECRET_BUCKET=$(aws cloudformation describe-stack-resources --stack-name ${STACK_NAME} --logical-resource-id=SecretExchangeBucket --output json 2> /dev/null | jq -r .StackResources[0].PhysicalResourceId)
        if [[ "$?" == "0" ]] ; then
            echo "Secret bucket is: ${K8S_SECRET_BUCKET}"
            K8S_CONFIG_FILENAME="config-${CLUSTER_NAME}.yaml"
            while true ; do
                aws s3 cp s3://${K8S_SECRET_BUCKET}/data/client/config "${K8S_CONFIG_FILENAME}" 2> /dev/null 1> /dev/null
                if [[ "$?" == "0" ]] ; then
                    echo
                    echo "Your Kubernetes cluster config file is stored locally as ${K8S_CONFIG_FILENAME}"
                    break
                else
                    printf "."
                    sleep 30
                fi
            done
            break
        else
            echo "Secret bucket is not baked in yet. Sleeping for 30 seconds."
            sleep 30
        fi
    done
}

#
# Wait for Kubernetes to start up.
# If Kubernetes doesn't appear as alive within one hour, the function will fail and interrupt script execution.
#
# Parameter: name of a stack
#
function wait_kubernetes_start() {
    STACK_NAME="${1}"
    local ATTEMPT=120
    export KUBECONFIG="$(pwd)/config-${CLUSTER_NAME}.yaml"

    echo "Waiting for Kubernetes to become available..."
    while true ; do
        ATTEMPT=$((ATTEMPT - 1))
        if [[ "${ATTEMPT}" == "0" ]] ; then
            echo "It takes too long to communicate to Kubernetes cluster installed in the stack ${STACK_NAME}, interrupting.
            \nPlease, use other means to check if anything's wrong with Kubernetes cluster."
            exit 1
        fi
        # We check the availability of Kubernetes by presence of kubernetes-dashboard service
        # which actually depends on a number of other system components.
        FOUND_SERVICE=$(kubectl get services --namespace kube-system 2> /dev/null | grep kubernetes-dashboard)
        if [[ "${FOUND_SERVICE}" != "" ]]; then
            break
        else
            printf "."
            sleep 30
        fi
    done

    echo
    echo "Kubernetes is up and running"
}

function print_cluster_info() {
    STACK_NAME="${1}"
    export KUBECONFIG="$(pwd)/config-${CLUSTER_NAME}.yaml"

    CONFIG_JSON=$(python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout, indent=4)' < "${KUBECONFIG}")
    URL=$(echo ${CONFIG_JSON} | jq -r .clusters[0].cluster.server)
    echo
    echo "Dashboard URL: ${URL}/ui"
    echo "Credentials for admin user are found at ${KUBECONFIG}"
    echo "Export a variable pointing your cluster's configuration file:
    $ export KUBECONFIG=${KUBECONFIG}

Good luck!
"
}

#
# Sequence of execution
#
function main() {
    launch_stack_creation "${STACK_NAME}"
    wait_stack_create_complete "${STACK_NAME}"

    download_config_file "${STACK_NAME}"

    wait_kubernetes_start "${STACK_NAME}"

    echo "Kubernetes cluster has been set up and configured successfully."

    print_cluster_info "${STACK_NAME}"
}

main
