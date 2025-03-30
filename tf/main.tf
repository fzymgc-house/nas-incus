

module "base" {
  source = "./modules/base"
}

module "nas-app-proxy" {
  source = "./modules/nas-app-proxy"
  container_bridge_network_name = module.base.container_bridge_network_name
}

module "nas-support" {
  source = "./modules/nas-support"
  container_bridge_network_name = module.base.container_bridge_network_name
}

module "nas-container-apps" {
  source = "./modules/nas-container-apps"
  container_bridge_network_name = module.base.container_bridge_network_name
}

