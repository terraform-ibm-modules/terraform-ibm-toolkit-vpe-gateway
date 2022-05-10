module "cos" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-object-storage"

  provision = true
  resource_group_name = module.resource_group.name
  name_prefix = var.name_prefix
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"

  bin_dir = "${path.cwd}/test_bin_dir"
  clis = ["ibmcloud-is"]
}

resource local_file bin_dir {
  filename = "${path.cwd}/.bin_dir"

  content = module.setup_clis.bin_dir
}
