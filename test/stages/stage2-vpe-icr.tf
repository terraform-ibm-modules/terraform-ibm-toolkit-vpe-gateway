module "vpe-icr" {
  source = "./module"

  resource_group_name = module.resource_group.name
  region              = var.region
  ibmcloud_api_key    = var.ibmcloud_api_key
  name_prefix         = local.name_prefix

  vpc_id              = module.subnets.vpc_id
  vpc_subnets         = module.subnets.subnets
  vpc_subnet_count    = module.subnets.count
  resource_label      = module.icr.label
  resource_crn        = module.icr.id
  resource_service    = module.icr.service
}

