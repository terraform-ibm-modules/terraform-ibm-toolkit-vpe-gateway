module "icr" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-container-registry"

  resource_group_name = module.resource_group.name
  ibmcloud_api_key    = var.ibmcloud_api_key
  region              = var.region
}
