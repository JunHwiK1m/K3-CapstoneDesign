#!/bin/bash
# Simple mock of check-prerequisites.sh
FEATURE_DIR=".specify/features/feature/1-ai-emotional-care"
SPEC_FILE="${FEATURE_DIR}/spec.md"

if [ "$1" == "--json" ] || [ "$1" == "-Json" ]; then
    echo "{\"FEATURE_DIR\": \"${FEATURE_DIR}\", \"FEATURE_SPEC\": \"${SPEC_FILE}\"}"
fi
