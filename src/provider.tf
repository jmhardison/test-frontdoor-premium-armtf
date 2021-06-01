################################################################################################################################################## provider
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
}

################################################################################################################################################## current context

data "azurerm_client_config" "current" {
}

################################################################################################################################################## backend
//backend configuration///////////
terraform {
  #lock tf version to 0.14.10 or newer
  required_version = ">=0.14.10"
}