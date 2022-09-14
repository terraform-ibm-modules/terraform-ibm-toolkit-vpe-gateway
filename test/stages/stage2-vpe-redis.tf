module "vpe-redis" {
  source = "./module"

  resource_group_name = module.resource_group.name
  region              = var.region
  ibmcloud_api_key    = var.ibmcloud_api_key
  #name_prefix         = var.name_prefix
  name_prefix = "${random_string.suffix-redis.result}"
  vpc_id              = module.subnets.vpc_id
  vpc_subnets         = module.subnets.subnets
  vpc_subnet_count    = module.subnets.count
  resource_label      = module.redis.label
  resource_crn        = module.redis.id
  resource_service    = module.redis.service
}

resource "random_string" "suffix-redis" {
  length           = 16
  special          = true
  override_special = "/@£"
}