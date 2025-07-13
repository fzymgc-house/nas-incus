# GitHub Actions Runner Container Plan

## Overview
This plan outlines the implementation of a local GitHub Actions runner using Incus containers within the existing NAS infrastructure.

## Implementation Steps

### 1. Terraform Infrastructure Module (`tf/modules/github-runner/`)
- Create container with appropriate resources (4-8 CPU cores, 8-16GB RAM)
- Attach to internal network for security
- Configure storage volume for runner workspace

### 2. Cloud-init Profile Configuration
- Install Docker and build tools
- Create runner user with sudo privileges
- Configure systemd service for runner daemon
- Pre-install common CI/CD dependencies

### 3. Ansible Role (`roles/github-runner/`)
- Download and install GitHub Actions runner binary
- Configure runner registration with PAT/app token
- Set up Docker-in-Docker for container workflows
- Configure runner labels and capabilities

### 4. Security & Networking
- Isolate on internal network with outbound-only access
- Configure fail2ban and firewall rules
- Implement runner token rotation
- Set up monitoring with Prometheus metrics

### 5. Orchestration Playbook
- Integrate with existing `main.yml` workflow
- Add `github-runners` tag for selective deployment
- Support multiple runner instances with unique names

## Task Tracking

1. ✅ Create Terraform module for GitHub runner container (PR #16: feat/github-runner-terraform-module)
   - Created module structure in `tf/modules/github-runner/`
   - Configured container with 4 CPU cores, 8GB RAM, 50GB storage
   - Internal network only for security
   - Integrated into main.tf
   - **PR Review Fixes Applied:**
     - Fixed naming inconsistency (runner_name default now "runner")
     - Added variable validation for all resource parameters
     - Replaced hardcoded storage pool with data source
     - Pinned Ubuntu image version (20250712_07:42)
     - Created comprehensive module README.md
     - Removed unused data source
2. ✅ Create cloud-init profile for runner initialization (PR: feat/github-runner-cloudinit-profile)
   - Created dedicated `github-runner` profile in `tf/modules/profiles/`
   - Configured cloud-init with:
     - Docker and Docker Compose installation
     - Development tools (Node.js, .NET SDKs, GitHub CLI)
     - Runner user with sudo and docker access
     - Systemd service template for GitHub runner
   - Enabled Docker-in-Docker support with privileged container
   - Updated GitHub runner module to use the new profile
3. Create Ansible role for GitHub runner setup
4. Add runner registration with GitHub organization/repo
5. Configure Docker-in-Docker support for container workflows
6. Create playbook to orchestrate runner deployment
7. Add security hardening and network isolation