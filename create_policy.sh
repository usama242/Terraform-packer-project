#!bin/bash

# Define the policy to deny resource creation without tags
az policy definition create --name tagging-policy --display-name "Enforce resource tagging policy" --description "This policy ensures all indexed resources in your subscription are tagged or else deny creation." --rules policy.json --mode Indexed --params param.json

# Assign the created policy
az policy assignment create --name tagging-policy --display-name "Enforce resource tagging assignment" --policy tagging-policy --params --% "{ \"tagName\": {\"value\": \"Name\"} }"

# I used powershell so I had to use --% to escape the quotes, however it is not
# needed in linux or mac.