#!/bin/bash

# Path to the EKS module main.tf file
MODULE_FILE=".terraform/modules/eks.eks/main.tf"

# Check if the file exists
if [ ! -f "$MODULE_FILE" ]; then
    echo "Error: Module file not found at $MODULE_FILE"
    echo "Make sure you've run 'terraform init' first"
    exit 1
fi

# Create a backup of the original file
cp "$MODULE_FILE" "${MODULE_FILE}.bak"

# Replace the resources attribute access
sed -i 's/resources = encryption_config.value.resources/resources = encryption_config.value[0].resources/g' "$MODULE_FILE"

# Replace the provider_key_arn attribute access
sed -i 's/key_arn = var.create_kms_key ? module.kms.key_arn : encryption_config.value.provider_key_arn/key_arn = var.create_kms_key ? module.kms.key_arn : encryption_config.value[0].provider_key_arn/g' "$MODULE_FILE"

echo "Patch applied successfully"
echo "Original file backed up to ${MODULE_FILE}.bak"