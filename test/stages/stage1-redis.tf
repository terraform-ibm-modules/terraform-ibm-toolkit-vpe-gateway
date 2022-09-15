module "redis" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-redis"

  resource_group_name = module.resource_group.name
  resource_location   = var.region
  name_prefix         = var.name_prefix
  private_endpoints   = true
}
