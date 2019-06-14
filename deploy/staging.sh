#!/bin/sh

set -e

# Setup basic gcloud config
gcloud --quiet config set container/cluster $KUBE_CLUSTER
gcloud --quiet container clusters get-credentials $KUBE_CLUSTER

# Push the new docker image
gcloud docker -- push gcr.io/${PROJECT}/${DOCKER_IMAGE}

# setting current context namespace
kubectl config set-context $(kubectl config current-context) --namespace=$CLUSTER_STAGING_NAMESPACE

# Display config
kubectl config view
kubectl config current-context

# Replace deployment image
kubectl set image deployment/${KUBE_DEPLOYMENT_NAME_STAGING} ${KUBE_DEPLOYMENT_CONTAINER_NAME_STAGING}=gcr.io/${PROJECT}/${DOCKER_IMAGE}:$CIRCLE_SHA1 --namespace=$CLUSTER_STAGING_NAMESPACE