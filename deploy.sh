#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENVIRONMENT="${1:-dev}"
TARGET_RG="${2:-rg-ae-revbc}"

case "$ENVIRONMENT" in
  dev|uat|prod) ;;
  *)
    echo "Invalid environment '$ENVIRONMENT'. Use one of: dev, uat, prod"
    exit 1
    ;;
esac

TAGS_JSON=$(jq -c --arg env "$ENVIRONMENT" '.[$env]' "$SCRIPT_DIR/tags.json")

az deployment group create \
  --resource-group "$TARGET_RG" \
  --template-file "$SCRIPT_DIR/main.bicep" \
  --parameters "@$SCRIPT_DIR/parameters.json" \
  --parameters environment="$ENVIRONMENT" \
  --parameters tags="$TAGS_JSON"
