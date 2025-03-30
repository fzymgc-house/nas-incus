

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

module "doorsportal1-server" {
  source = "./modules/ares-server"
  hwaddr = "00:16:3e:ae:0c:f2"
  server_name = "doorsportal1"
  server_description = "Doors Portal 1"
  server_image = "ubuntu/oracular/cloud"
  server_source_dir = "/mnt/main/fzymgc-house/incus/storage/doorsportal1/server"
  server_database_dir = "/mnt/main/fzymgc-house/incus/storage/doorsportal1/database"
}

module "precipice-server" {
  source = "./modules/ares-server"
  hwaddr = "00:16:3e:ae:0c:f1"
  server_name = "precipice"
  server_description = "Precipice"
  server_image = "ubuntu/oracular/cloud"
  server_source_dir = "/mnt/main/fzymgc-house/incus/storage/precipice/server"
  server_database_dir = "/mnt/main/fzymgc-house/incus/storage/precipice/database"
}
