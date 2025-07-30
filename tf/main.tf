

module "base" {
  source = "./modules/base"
}

import {
  to = module.base.incus_project.default
  id = "default"
}

import {
  to = module.base.incus_network.incusbr0
  id = "incusbr0"
}

import {
  to = module.base.incus_storage_pool.default
  id = "default"
}

module "profiles" {
  source                        = "./modules/profiles"
  container_bridge_network_name = module.base.container_bridge_network_name
}

import {
  to = module.profiles.incus_profile.default
  id = "default"
}


module "nas-app-proxy" {
  depends_on                    = [module.profiles]
  source                        = "./modules/nas-app-proxy"
  container_bridge_network_name = module.base.container_bridge_network_name
}


module "nas-support" {
  depends_on                    = [module.profiles]
  source                        = "./modules/nas-support"
  container_bridge_network_name = module.base.container_bridge_network_name
}

module "nas-container-apps" {
  depends_on                    = [module.profiles]
  source                        = "./modules/nas-container-apps"
  container_bridge_network_name = module.base.container_bridge_network_name
}

module "doorsportal1-server" {
  depends_on          = [module.profiles]
  source              = "./modules/ares-server"
  hwaddr              = "00:16:3e:ae:0c:f2"
  server_name         = "doorsportal1"
  server_description  = "Doors Portal 1"
  server_image        = "ubuntu/oracular/cloud"
  server_source_dir   = "/mnt/main/fzymgc-house/incus/storage/doorsportal1/server"
  server_database_dir = "/mnt/main/fzymgc-house/incus/storage/doorsportal1/database"
}

module "precipice-server" {
  depends_on          = [module.profiles]
  source              = "./modules/ares-server"
  hwaddr              = "00:16:3e:ae:0c:f1"
  server_name         = "precipice"
  server_description  = "Precipice"
  server_image        = "ubuntu/oracular/cloud"
  server_source_dir   = "/mnt/main/fzymgc-house/incus/storage/precipice/server"
  server_database_dir = "/mnt/main/fzymgc-house/incus/storage/precipice/database"
}

module "github-runners" {
  depends_on   = [module.profiles]
  source       = "./modules/github-runner"
  runner_count = 1
  runner_name  = "gh-runner"
}
