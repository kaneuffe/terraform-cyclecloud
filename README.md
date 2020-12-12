# terraform-cyclecloud
Terraform templates for an Azure CycleCloud HPC deployment 

# Requirements
## Permissions
To be able to run this terraform template yourself or a already created service principle need to have the following permissions:
- OWNER rights for the subscription in scope
- CONTRIBUTOR and USER ACCESS ADMINISTRATOR for the subscription in scope
## Environment variables
To run the templates, you need to set the following environment variables:
- TF_VAR_admin_username (CycleCloud VM OS administrator username)
- TF_VAR_admin_password (CycleCLoud VM OS administrator password - to make password authentication to work please change "disable_password_authentication = false" in the main.tf template)
- TF_VAR_admin_key_data (CyclecCloud VM OS administrator public ssh key)
- TF_VAR_cyclecloud_username (CycleCloud GUI administrator username)
- TF_VAR_cyclecloud_password (CycleCloud GUI administrator username)
- TF_VAR_cyclecloud_public_access_address_prefixes (Your IP address range to avoid other IPs to access the environment)

additionally if you want to use a service principle instead of "az login" the following, additional environment variables need to be defined:

- ARM_CLIENT_ID
- ARM_CLIENT_SECRET
- ARM_SUBSCRIPTION_ID
- ARM_TENANT_ID

# GitHub actions
To run the terraform template as an GitHub action, the follwing secrets need to be defined:
- TF_ARM_CLIENT_ID
- TF_ARM_CLIENT_SECRET
- TF_ARM_SUBSCRIPTION_ID
- TF_ARM_TENANT_ID
- TF_VAR_ADMIN_USERNAME
- TF_VAR_ADMIN_PASSWORD
- TF_VAR_ADMIN_KEY_DATA
- TF_VAR_CYCLECLOUD_USERNAME
- TF_VAR_CYCLECLOUD_PASSWORD
- TF_VAR_CYCLECLOUD_PUBLIC_ACCESS_ADDRESS_PREFIXES
