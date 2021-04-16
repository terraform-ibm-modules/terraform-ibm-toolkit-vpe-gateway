module "redis" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-redis"

  resource_group_name = var.resource_group_name
  resource_location   = var.region
  name_prefix         = var.name_prefix
  ibmcloud_api_key    = var.ibmcloud_api_key
}
