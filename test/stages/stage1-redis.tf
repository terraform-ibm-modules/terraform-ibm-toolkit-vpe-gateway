module "redis" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-redis"

  provision = true
  resource_group_name = module.resource_group.name
  name_prefix = var.name_prefix
}
