#!/bin/bash
set -euo pipefail

# -------------------------------------------------------
# deploy.sh - Deploy Bicep infrastructure for revbc
# Usage: ./deploy.sh <environment>
# Example: ./deploy.sh dev
# -------------------------------------------------------

ENVIRONMENT=${1:?"Usage: ./deploy.sh <environment> (dev|uat|prod)"}
RESOURCE_GROUP="rg-ae-revbc"
TEMPLATE_FILE="main.bicep"
PARAMETERS_FILE="parameters/parameters.json"
TAGS_FILE="parameters/tags.json"

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|uat|prod)$ ]]; then
  echo "Error: Environment must be one of: dev, uat, prod"
  exit 1
fi

# Check parameter file exists
if [ ! -f "$PARAMETERS_FILE" ]; then
  echo "Error: Parameters file not found: $PARAMETERS_FILE"
  exit 1
fi

echo "============================================"
echo "Deploying to environment: $ENVIRONMENT"
echo "Resource Group: $RESOURCE_GROUP"
echo "Template: $TEMPLATE_FILE"
echo "Parameters: $PARAMETERS_FILE"
echo "============================================"

# Build tags parameter as JSON object for Bicep
TAGS_JSON=$(jq --arg env "$ENVIRONMENT" '. + {"Environment": $env}' "$TAGS_FILE")

# Deploy the Bicep template
az deployment group create \
  --resource-group "$RESOURCE_GROUP" \
  --template-file "$TEMPLATE_FILE" \
  --parameters "$PARAMETERS_FILE" \
  --parameters environment="$ENVIRONMENT" \
  --parameters tags="$TAGS_JSON" \
  --parameters sqlAdminPassword="$(az keyvault secret show --vault-name kv-ae-revbc --name sql-admin-password --query value -o tsv)" \
  --name "deploy-${ENVIRONMENT}-$(date +%Y%m%d%H%M%S)" \
  --verbose

echo "============================================"
echo "Deployment to $ENVIRONMENT completed successfully."
echo "============================================"
