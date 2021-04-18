#!/usr/bin/env bash

CRN="$1"
SERVICE="$2"
REGION="$3"
RESOURCE_GROUP="$4"
OUTPUT_FILE="$5"

if [[ -z "${IBMCLOUD_API_KEY}" ]]; then
  echo "IBMCLOUD_API_KEY is required as an environment variable"
  exit 1
fi

if [[ -z "${TMP_DIR}" ]]; then
  TMP_DIR="./tmp"
fi
mkdir -p "${TMP_DIR}"

echo "Logging into the ibmcloud account: region=${REGION}, resource_group=${RESOURCE_GROUP}"
ibmcloud login --apikey "${IBMCLOUD_API_KEY}" -r "${REGION}" -g "${RESOURCE_GROUP}" || exit 1

TMP_OUTPUT="${TMP_DIR}/endpoints.tmp"

echo "Getting endpoint gateway targets"
ibmcloud is endpoint-gateway-targets --output JSON > "${TMP_OUTPUT}"
if [[ "${SERVICE}" == "cloud-object-storage" ]]; then
  echo "Looking up object storage crn"
  cat "${TMP_OUTPUT}" | \
    jq --arg SERVICE "${SERVICE}" --arg REGION "${REGION}" '.[] | select(.crn) | select(.crn|test($SERVICE)) | select(.crn|test($REGION))' > "${OUTPUT_FILE}"
else
  echo "Looking up crn: ${CRN}"
  cat "${TMP_OUTPUT}" | \
    jq --arg CRN "${CRN}" '.[] | select(.crn) | select(.crn == $CRN)' > "${OUTPUT_FILE}"
fi

if [[ -z "$(cat "${OUTPUT_FILE}")" ]]; then
  echo "The output file is empty"
  # Create the file with an empty object to satisy destroy
  echo "{}" > "${OUTPUT_FILE}"
  exit 1
else
  echo "Found matching resource:"
  echo "  CRN:           $(cat "${OUTPUT_FILE}" | jq '.crn')"
  echo "  Resource type: $(cat "${OUTPUT_FILE}" | jq '.resource_type')"
fi
