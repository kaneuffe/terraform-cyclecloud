# terraform-cyclecloud
Terraform templates for an Azure cyclecloud HPC deployment 

# requirements
To run the templates, youn need to set the following environment varibles
- ARM_CLIENT_ID: ${{secrets.TF_ARM_CLIENT_ID}}
- ARM_CLIENT_SECRET: ${{secrets.TF_ARM_CLIENT_SECRET}}
- ARM_SUBSCRIPTION_ID: ${{secrets.TF_ARM_SUBSCRIPTION_ID}}
- ARM_TENANT_ID: ${{secrets.TF_ARM_TENANT_ID}}
- TF_VAR_admin_username: ${{secrets.TF_VAR_ADMIN_USERNAME}}
- TF_VAR_admin_password: ${{secrets.TF_VAR_ADMIN_PASSWORD}}
- TF_VAR_admin_key_data: ${{secrets.TF_VAR_ADMIN_KEY_DATA}}
- TF_VAR_cyclecloud_username: ${{secrets.TF_VAR_CYCLECLOUD_USERNAME}}
- TF_VAR_cyclecloud_password: ${{secrets.TF_VAR_CYCLECLOUD_PASSWORD}}
- TF_VAR_cyclecloud_public_access_address_prefixes: ${{secrets.TF_VAR_CYCLECLOUD_PUBLIC_ACCESS_ADDRESS_PREFIXES}}
      
            ARM_CLIENT_ID: ${{secrets.TF_ARM_CLIENT_ID}}
      ARM_CLIENT_SECRET: ${{secrets.TF_ARM_CLIENT_SECRET}}
      ARM_SUBSCRIPTION_ID: ${{secrets.TF_ARM_SUBSCRIPTION_ID}}
      ARM_TENANT_ID: ${{secrets.TF_ARM_TENANT_ID}}
      TF_VAR_admin_username: ${{secrets.TF_VAR_ADMIN_USERNAME}}
      TF_VAR_admin_password: ${{secrets.TF_VAR_ADMIN_PASSWORD}}
      TF_VAR_admin_key_data: ${{secrets.TF_VAR_ADMIN_KEY_DATA}}
      TF_VAR_cyclecloud_username: ${{secrets.TF_VAR_CYCLECLOUD_USERNAME}}
      TF_VAR_cyclecloud_password: ${{secrets.TF_VAR_CYCLECLOUD_PASSWORD}}
      TF_VAR_cyclecloud_public_access_address_prefixes: ${{secrets.TF_VAR_CYCLECLOUD_PUBLIC_ACCESS_ADDRESS_PREFIXES}}
