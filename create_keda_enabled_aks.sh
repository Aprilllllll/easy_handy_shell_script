#!/bin/bash

set -e
set -x

export SERVICE="aks"
export CLUSTER_NAME="keda0"
export RG_NAME="rg-${CLUSTER_NAME}-${SERVICE}"
export LOCATION="centralus"

az group create -n ${RG_NAME} -l ${LOCATION}

az aks create --name "$CLUSTER_NAME" --resource-group "$RG_NAME" --node-count 3 --enable-managed-identity --enable-workload-identity --enable-oidc-issuer --generate-ssh-keys --enable-keda --no-wait   

echo "Waiting for AKS cluster to be ready......"
az aks wait --name "$CLUSTER_NAME" --resource-group "$RG_NAME" --created

echo "Checking oidc issuer......"
az aks show --name "${CLUSTER_NAME}" \
    --resource-group "${RG_NAME}" \
    --query "oidcIssuerProfile.issuerUrl" \
    --output tsv

echo "Checking KEDA extension......"
az aks show --resource-group "${RG_NAME}" --name "${CLUSTER_NAME}" --query "workloadAutoScalerProfile.keda.enabled"

echo "We are all set!! Getting AKS credentials......"
az aks get-credentials --name "$CLUSTER_NAME" --resource-group "$RG_NAME"

echo "KEDA enabled AKS cluster is all set, enjoy!"
