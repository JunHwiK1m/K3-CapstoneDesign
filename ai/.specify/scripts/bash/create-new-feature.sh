#!/bin/bash
DESCRIPTION=$1
SHORT_NAME=""
TITLE=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --short-name) SHORT_NAME="$2"; shift ;;
        --json) JSON_FLAG=true ;;
    esac
    shift
done

# 브랜치 번호 자동 계산 (단순화된 버전)
NEXT_NUM=1
BRANCH_NAME="feature/${NEXT_NUM}-${SHORT_NAME}"
SPEC_DIR=".specify/features/${BRANCH_NAME}"
SPEC_FILE="${SPEC_DIR}/spec.md"

mkdir -p "${SPEC_DIR}/checklists"
git checkout -b "${BRANCH_NAME}" 2>/dev/null || git checkout "${BRANCH_NAME}"

if [ "$JSON_FLAG" = true ]; then
    echo "{\"BRANCH_NAME\": \"${BRANCH_NAME}\", \"SPEC_FILE\": \"${SPEC_FILE}\", \"FEATURE_DIR\": \"${SPEC_DIR}\"}"
fi
