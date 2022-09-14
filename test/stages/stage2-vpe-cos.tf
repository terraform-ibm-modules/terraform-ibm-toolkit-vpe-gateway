module "vpe-cos" {
  source = "./module"

  resource_group_name = module.resource_group.name
  region              = var.region
  ibmcloud_api_key    = var.ibmcloud_api_key
  #name_prefix         = var.name_prefix
  name_prefix = "${random_string.suffix-cos.result}"
  vpc_id              = module.subnets.vpc_id
  vpc_subnets         = module.subnets.subnets
  vpc_subnet_count    = module.subnets.count
  resource_label      = module.cos.label
  resource_crn        = module.cos.id
  resource_service    = module.cos.service
}

resource "random_string" "suffix-cos" {
  length           = 16
  special          = false
  upper = false
  override_special = "/*$"
}