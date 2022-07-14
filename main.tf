locals {
  tmp_dir         = "${path.cwd}/.tmp/${local.name}"
  crn_file_name   = "${local.tmp_dir}/endpoint-gateway-targets.json"
  prefix_name     = var.name_prefix != "" ? var.name_prefix : var.resource_group_name
  name            = lower(replace("${local.prefix_name}-vpe-${var.resource_label}", "_", "-"))
}

resource null_resource setup {
  provisioner "local-exec" {
    command = "echo 'Resource group name: ${var.resource_group_name}'"
  }
  provisioner "local-exec" {
    command = "echo 'Resource crn: ${var.resource_crn}'"
  }
  provisioner "local-exec" {
    command = "echo 'Sync value: ${var.sync}'"
  }
  provisioner "local-exec" {
    command = "echo 'Subnets: ${jsonencode(var.vpc_subnets[*].id)}'"
  }
}

resource time_sleep wait_for_resource_initialization {
  depends_on = [null_resource.setup]

  create_duration = "3m"
}

module setup_clis {
  source = "cloud-native-toolkit/clis/util"

  clis = ["jq", "ibmcloud-is"]
}

data external endpoint-target {
  depends_on = [null_resource.setup, time_sleep.wait_for_resource_initialization]

  program = ["bash", "${path.module}/scripts/get-endpoint-target.sh"]

  query = {
    bin_dir = module.setup_clis.bin_dir
    resource_crn = var.resource_crn
    resource_service = var.resource_service
    region = var.region
    resource_group_name = var.resource_group_name
    ibmcloud_api_key = var.ibmcloud_api_key
    tmp_dir = local.tmp_dir
  }
}

data ibm_resource_group resource_group {
  depends_on = [null_resource.setup]

  name = var.resource_group_name
}

data ibm_is_subnet subnets {
  count = var.vpc_subnet_count

  identifier = var.vpc_subnets[count.index].id
}

resource ibm_is_virtual_endpoint_gateway vpe-gateway {
  depends_on = [time_sleep.wait_for_resource_initialization]

  name           = local.name
  vpc            = var.vpc_id
  resource_group = data.ibm_resource_group.resource_group.id
  tags           = [var.resource_label]

  target {
    crn           = data.external.endpoint-target.result.crn
    resource_type = data.external.endpoint-target.result.resource_type
  }

  # One reserved IP per zone in the VPC in the VPE subnets
  dynamic "ips" {
    for_each = {for subnet in data.ibm_is_subnet.subnets : subnet.id => subnet}
    content {
      subnet = ips.key
      name = "${ips.value.name}-${var.resource_label}"
    }
  }
}
