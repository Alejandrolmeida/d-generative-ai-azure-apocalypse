#!/bin/bash

set -e

scriptDir=$(dirname "$(realpath "$0")")

# Load environment variables from .env file
if [ -f "$scriptDir/../.env" ]; then
    source "$scriptDir/../.env"
fi

function login {
    az login --use-device-code -t $TENANT_ID
    az account set --subscription $SUBSCRIPTION_ID
}

function check_login {
    echo "Checking Azure login status..."
    if [ -z "$(az account show)" ]; then
        echo "Not logged in to Azure. Initiating login..."
        login
    else
        echo "Already logged in to Azure."
    fi
}

function create_resource_group {
    echo "Creating resource group $RESOURCE_GROUP_CHAOS in $LOCATION..."
    if [ -z "$(az group show --name $RESOURCE_GROUP_CHAOS)" ]; then
        az group create --name $RESOURCE_GROUP_CHAOS --location $LOCATION > /dev/null
        az group wait --name $RESOURCE_GROUP --created   
    else 
        echo "Resource group $RESOURCE_GROUP_CHAOS already exists. Skipping creation..."
    fi
}

function provision_resources {
    echo "Provisioning resources in resource group $RESOURCE_GROUP_CHAOS..."
    az deployment group create \
        --resource-group $RESOURCE_GROUP_CHAOS \
        --name $DEPLOYMENT_NAME \
        --template-file azureapocalypse.bicep \
        --parameters location=$LOCATION prefix=$PROJECT_NAME > /dev/null
}

function main {
    check_login
    create_resource_group
    provision_resources

    echo "Provisioning complete!"
}

main