#!/bin/sh

set -e

echo ${GOOGLE_AUTH} > ${HOME}/gcp-key.json
gcloud auth activate-service-account --key-file ${HOME}/gcp-key.json
gcloud --quiet config set project ${PROJECT}
gcloud config set compute/zone ${ZONE}
gcloud auth configure-docker