#!bin/bash

# Define the policy to deny resource creation without tags
az policy definition create --name tagging-policy --display-name "Enforce resource tagging policy" --description "This policy ensures all indexed resources in your subscription are tagged or else deny creation." --rules policy.json --mode Indexed

# Assign the created policy
az policy assignment create --name tagging-policy --display-name "Enforce resource tagging assignment" --policy "tagging-policy"