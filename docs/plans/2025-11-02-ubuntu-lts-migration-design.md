# Ubuntu LTS Migration Design

**Date:** 2025-11-02
**Status:** Approved
**Containers:** precipice, doorsportal1

## Overview

Migrate AreMUSH game server containers from Ubuntu 24.10 (Oracular) to Ubuntu 24.04 LTS (Noble) for improved long-term stability and support.

## Scope and Impact

### What's Changing

- Both `precipice` and `doorsportal1` containers will use `ubuntu/noble/cloud` instead of `ubuntu/oracular/cloud`
- Single-line Terraform configuration change in `tf/main.tf` for each module

### Impact Analysis

**Container Recreation:**

- Terraform will detect image change and recreate containers (destroy + create cycle)
- Estimated downtime: 2-5 minutes per container

**Data Preservation:**

- Game data mounted at `/home/ares` from host filesystem persists
- Database mounted at `/var/lib/valkey` from host filesystem persists
- No data loss expected

**Network Consistency:**

- MAC addresses pinned in Terraform configuration
- DHCP leases should remain consistent
- DNS resolution via FQDN should continue working

### Support Window

- **Current:** Ubuntu 24.10 (Oracular) - supported until July 2025
- **Target:** Ubuntu 24.04 LTS (Noble) - supported until April 2029

## Implementation Approach

### Execution Order

Update containers sequentially (not in parallel) to minimize risk:

1. **Phase 1:** doorsportal1 (requested first)
2. **Phase 2:** precipice (after verifying Phase 1 success)

### Terraform Changes

**File:** `tf/main.tf`

**doorsportal1 (line 66):**

```hcl
# Before
server_image = "ubuntu/oracular/cloud"

# After
server_image = "ubuntu/noble/cloud"
```

**precipice (line 82):**

```hcl
# Before
server_image = "ubuntu/oracular/cloud"

# After
server_image = "ubuntu/noble/cloud"
```

## Step-by-Step Process

### Phase 1: Update doorsportal1

1. Modify `tf/main.tf:66` to change image reference
2. Run `cd tf && terraform plan` to verify change detection
3. Run `terraform apply` to recreate container
4. Verify container status with `incus list --project default`
5. Verify AreMUSH service is running (SSH check or systemd status)
6. Test game port connectivity: `nc -zv <container-ip> 4211`

### Phase 2: Update precipice

1. Modify `tf/main.tf:82` to change image reference
2. Run `cd tf && terraform plan` to verify change detection
3. Run `terraform apply` to recreate container
4. Verify container status with `incus list --project default`
5. Verify AreMUSH service is running (SSH check or systemd status)
6. Test game port connectivity: `nc -zv <container-ip> 4201`

## Verification Checklist

For each container after recreation:

- [ ] Container shows "RUNNING" status in `incus list`
- [ ] Container has obtained IP address via DHCP
- [ ] Container is reachable via FQDN (ping test)
- [ ] SSH access works
- [ ] AreMUSH process/service is running
- [ ] Game port is accepting connections
- [ ] Mounted volumes show correct data

## Rollback Plan

If issues occur with either container:

1. Revert `server_image` value to `"ubuntu/oracular/cloud"` in `tf/main.tf`
2. Run `terraform apply` to recreate with original image
3. Verify services return to normal operation

## Dependencies

- Terraform Cloud workspace: fzymgc-house/incus-nas
- Incus remote: 192.168.20.200:2443
- Host filesystem mounts must remain accessible
- DHCP server must be operational

## Risk Assessment

**Low Risk:**

- Single configuration parameter change
- Data persists on host filesystem
- Network configuration remains unchanged
- Rollback is straightforward

**Mitigation:**

- Sequential updates allow validation between phases
- Rollback plan documented and tested
- Downtime window is brief (2-5 minutes per container)
