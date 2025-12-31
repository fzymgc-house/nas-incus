

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

import {
  to = module.base.incus_storage_pool.apps
  id = "apps"
}

module "profiles" {
  source = "./modules/profiles"
}

import {
  to = module.profiles.incus_profile.default
  id = "default"
}

module "nas_support" {
  depends_on                    = [module.profiles]
  source                        = "./modules/nas-support"
  container_bridge_network_name = module.base.container_bridge_network_name
  server_image                  = module.base.container_ubuntu_2504_image_name
  storage_pool                  = module.base.storage_pool_apps_name
}

module "nas_container_apps" {
  depends_on                    = [module.profiles]
  source                        = "./modules/nas-container-apps"
  container_bridge_network_name = module.base.container_bridge_network_name
  server_image                  = module.base.container_ubuntu_2504_image_name
  storage_pool                  = module.base.storage_pool_apps_name
}

module "doorsportal1_server" {
  depends_on          = [module.profiles]
  source              = "./modules/ares-server"
  hwaddr              = "00:16:3e:ae:0c:f2"
  server_name         = "doorsportal1"
  server_description  = "Doors Portal 1"
  server_image        = module.base.container_ubuntu_2504_image_name
  server_source_dir   = "/mnt/main/fzymgc-house/incus/storage/doorsportal1/server"
  server_database_dir = "/mnt/main/fzymgc-house/incus/storage/doorsportal1/database"
  storage_pool        = module.base.storage_pool_apps_name
}

module "precipice_server" {
  depends_on          = [module.profiles]
  source              = "./modules/ares-server"
  hwaddr              = "00:16:3e:ae:0c:f1"
  server_name         = "precipice"
  server_description  = "Precipice"
  server_image        = module.base.container_ubuntu_2504_image_name
  server_source_dir   = "/mnt/main/fzymgc-house/incus/storage/precipice/server"
  server_database_dir = "/mnt/main/fzymgc-house/incus/storage/precipice/database"
  storage_pool        = module.base.storage_pool_apps_name
}

module "github_runners" {
  depends_on   = [module.profiles]
  source       = "./modules/github-runner"
  runner_count = 1
  runner_name  = "gh-runner"
  storage_pool = module.base.storage_pool_apps_name
}
