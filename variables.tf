variable "prefix" {
  description = "The Prefix used for all CycleCloud VM resources"
  default = "acc"
}

variable "location" {
  description = "The Azure Region in which to run CycleCloud"
  default = "westeurope"
}

variable "machine_type" {
  description = "The Azure Machine Type for the CycleCloud VM"
  default = "Standard_D8s_v3"
}

variable "cyclecloud_computer_name" {
    description =  "The private hostname for the CycleCloud VM"
    default = "accserver"
}

variable "admin_username" {
  description = "The username for the CycleCloud VM Admin user and VM user"
}

variable "admin_password" {
  description = "The password for the CycleCloud VM Admin user"
}

variable "admin_key_data" {
  description = "The public SSH key for the CycleCloud VM admin"
}

variable "cyclecloud_username" {
  description = "The username for the initial CycleCloud Admin user and VM user"
}

variable "cyclecloud_password" {
  description = "The initial password for the CycleCloud Admin user"
}

variable "cyclecloud_tenant_id" {
  description = "Azure Tenant ID"
}

variable "cyclecloud_public_access_address_prefixes"{
  description = "PublicIP address ranges allowed to connect to CycleCloud"
}

# Storage account name can contain only lowercase letters and numbers.
variable "cyclecloud_storage_account" {
  description = "Name of storage account to use for Azure CycleCloud storage locker"
  default = "accstorage"
}