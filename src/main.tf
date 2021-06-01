################################################################################################################################################## random setup
# create tenant unique ID for name uniqueness
resource "random_id" "randomId" {
  byte_length = 1
}


################################################################################################################################################## locals

locals {
  test_name = "fdpjhlabstst"
  randombit = "1ax"
}

################################################################################################################################################## resource group
# RG - For encap of test resources
resource "azurerm_resource_group" "fd_test_rg" {
  name     = format("rg%s%s", local.test_name, local.randombit)
  location = "North Central US"
}