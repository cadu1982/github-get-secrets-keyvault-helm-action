#!/bin/bash

VAULT_NAME=$VAULT_NAME

APP_REFERENCE=$APP_REFERENCE

GET_AZ_SECRETS_LIST=$(az keyvault secret list --vault-name $VAULT_NAME --query "[?contains(name, '$APP_REFERENCE')] [].[name]" --output tsv)

SET_ENV=""

for secret in $GET_AZ_SECRETS_LIST
do
    SHORT_AZ_SECRET_NAME=$(echo $secret | sed 's/'-$APP_REFERENCE'//g')
    SECRET_NAME=$(echo $SHORT_AZ_SECRET_NAME | tr '[:lower:]' '[:upper:]' | sed 's/\--/__/g' | sed 's/\-/_/g' )
    SECRET_VALUE=$(az keyvault secret show --name $secret --vault-name $VAULT_NAME --query "value" --output tsv | sed 's/\\/\\\\\\/g;s/\//\\\//g;s/\$/\\$/g;s/\*/\\*/g;s/\=/\\=/g;s/\!/\\!/g;s/\,/\\,/g;s/\&/\\&/g')
    echo "::add-mask::$SECRET_VALUE"
    SET_ENV+="--set env.$SECRET_NAME=\"$SECRET_VALUE\" "
done

echo "SET_ENV=$SET_ENV" >> $GITHUB_ENV
