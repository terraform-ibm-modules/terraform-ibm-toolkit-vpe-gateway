#!/usr/bin/env bash

INPUT=$(tee)

BIN_DIR=$(echo "${INPUT}" | grep "bin_dir" | sed -E 's/.*"bin_dir": ?"([^"]*)".*/\1/g')

export PATH="${BIN_DIR}:${PATH}"

if ! command -v jq 1> /dev/null 2> /dev/null; then
  echo "jq cli not found" >&2
  exit 1
fi

CRN=$(echo "${INPUT}" | jq -r '.resource_crn // empty')
SERVICE=$(echo "${INPUT}" | jq -r '.resource_service // empty')
REGION=$(echo "${INPUT}" | jq -r '.region //empty')
RESOURCE_GROUP=$(echo "${INPUT}" | jq -r '.resource_group_name // empty')
IBMCLOUD_API_KEY=$(echo "${INPUT}" | jq -r '.ibmcloud_api_key // empty')
TMP_DIR=$(echo "${INPUT}" | jq -r '.tmp_dir // empty')

if [[ -z "${IBMCLOUD_API_KEY}" ]]; then
  echo "IBMCLOUD_API_KEY is required" >&2
  exit 1
fi

if [[ -z "${TMP_DIR}" ]]; then
  TMP_DIR=".tmp/vpe-gateway"
fi
mkdir -p "${TMP_DIR}"

ibmcloud login -r "${REGION}" --apikey "${IBMCLOUD_API_KEY}" 1> /dev/null && ENDPOINT_TARGETS=$(ibmcloud is endpoint-gateway-targets --output JSON)

if [[ "${SERVICE}" == "cloud-object-storage" ]] || [[ "${SERVICE}" == "container-registry" ]]; then
  OUTPUT=$(echo "${ENDPOINT_TARGETS}" | \
    jq --arg SERVICE "${SERVICE}" --arg REGION "${REGION}" '.[] | select(.crn) | select(.crn|test($SERVICE)) | select(.crn|test($REGION))')

  if [[ -n "${OUTPUT}" ]]; then
    echo "${OUTPUT}" | jq '{"crn": .crn, "resource_type": .resource_type}'
    exit 0
  fi
else
  OUTPUT=$(echo "${ENDPOINT_TARGETS}" | \
    jq --arg CRN "${CRN}" '.[] | select(.crn) | select(.crn == $CRN)')

  if [[ -n "${OUTPUT}" ]]; then
    echo "${OUTPUT}" | jq '{"crn": .crn, "resource_type": .resource_type}'
    exit 0
  fi
fi

echo "Unable to find endpoint: ${CRN}, ${SERVICE}, ${REGION}" >&2
exit 1
