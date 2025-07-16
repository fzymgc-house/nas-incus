# GitHub Runner Bug Fix Plan

## Overview
This document outlines the plan to address bugs and issues identified in PR #22 for the GitHub runner infrastructure.

## Priority Classification
- 🔴 **Critical**: Breaking bugs that prevent functionality
- 🟡 **High**: Functional bugs that impact operations
- 🟠 **Medium**: Code quality and best practice issues
- 🟢 **Low**: Performance optimizations and nice-to-haves

## Issues to Address

### 🔴 Critical Bugs

#### 1. MAC Address Conflicts ✅ FIXED (PR #23)
**Location**: `tf/modules/github-runner/main.tf:33`
**Issue**: Hardcoded MAC addresses could conflict with multiple runners
**Fix Applied**: 
- Changed from `"00:16:3e:ae:aa:0${count.index + 3}"` to `format("00:16:3e:ae:aa:%02x", count.index + 3)`
- Now properly generates hexadecimal MAC addresses for 10+ runners
- **Status**: Completed in PR #23

#### 2. Network Interface Mismatch ✅ FIXED (PR #23)
**Location**: `tf/modules/github-runner/main.tf:17`
**Issue**: `user.access_interface` set to eth1 but only eth0 configured
**Fix Applied**:
- Changed `user.access_interface` from "eth1" to "eth0"
- **Status**: Completed in PR #23

### 🟡 High Priority Issues

#### 3. Service Dependencies ✅ FIXED (PR #24)
**Location**: `tf/modules/profiles/github-runner/cloud-init.user-data.yaml:156-158`
**Issue**: GitHub runner service may start before Docker is ready
**Fix Applied**:
- Added `After=docker.service` to systemd unit
- Added `Requires=docker.service` for hard dependency
- Implemented health check before starting runner
- **Status**: Completed in PR #24 (pending review improvements)

#### 4. Missing Error Handling ✅ FIXED (PR #24)
**Locations**: 
- Git configuration: `tf/modules/profiles/github-runner/cloud-init.user-data.yaml:138-141`
- Package installation: `tf/modules/profiles/github-runner/cloud-init.user-data.yaml:144-149`
**Fix Applied**:
- Added `|| echo "Warning..."` for non-critical commands
- Added proper error checking for critical operations
- All failures now logged to cloud-init output
- **Status**: Completed in PR #24 (pending review improvements)

### 🟠 Medium Priority Issues

#### 5. DNS Configuration Duplication 🔄 PENDING
**Location**: `inventory/production.yml:117-118`
**Issue**: DNS settings duplicated between inventory and cloud-init
**Fix**:
- Centralize DNS configuration in group_vars
- Remove duplication from cloud-init
- Use Ansible variables for consistency

### 🟢 Low Priority Improvements

#### 6. Performance Optimizations 🔄 PENDING
- Parallel package installation in cloud-init
- Use package lists instead of individual installs
- Consider pre-built container images

#### 7. Test Coverage 🔄 PENDING
- Add Terraform validation tests
- Create integration tests for runner deployment
- Add monitoring and health checks

## Implementation Status

### ✅ Phase 1: Critical Bug Fixes (COMPLETED)
**PR #23**: https://github.com/fzymgc-house/nas-incus/pull/23
- ✅ Fixed MAC address generation for multiple runners
- ✅ Corrected network interface configuration
- ✅ All tests passed (terraform validate, terraform plan)
- ✅ PR merged to main

### ✅ Phase 2: Service Reliability (COMPLETED)
**PR #24**: https://github.com/fzymgc-house/nas-incus/pull/24
- ✅ Fixed service dependencies with hard Docker requirement
- ✅ Added comprehensive error handling to cloud-init
- ✅ Added Docker daemon health check before runner starts
- ✅ All tests passed (terraform validate, ansible syntax check)
- ✅ Addressed all review feedback:
  - Added timeout protection (5 minutes) to Docker health check
  - Changed GitHub CLI to warning-only (optional component)
  - Fixed race condition by verifying Docker before usermod
- ✅ PR merged to main

### 🔄 Phase 3: Code Quality (PENDING)
- [ ] Resolve configuration duplication
- [ ] Implement proper logging
- [ ] Add monitoring

### 🔄 Phase 4: Testing & Optimization (FUTURE)
- [ ] Add test coverage
- [ ] Performance optimizations
- [ ] Documentation updates

## Testing Strategy

### Phase 1 Tests (Completed)
- ✅ Terraform validate passed
- ✅ Terraform plan showed only expected changes
- ✅ MAC address generation tested for 10 runners
- ✅ No unintended infrastructure changes

### Phase 2 Tests (Planned)
- Service startup verification
- Reboot testing
- Docker dependency validation
- Error recovery testing

### Phase 3 Tests (Planned)
- Configuration consistency checks
- Log aggregation verification
- Monitoring dashboard validation

## Current Branch Status
- **Phase 1 Branch**: `fix/phase1-mac-network-bugs` - PR #23 (Merged)
- **Phase 2 Branch**: `fix/phase2-service-reliability` - PR #24 (Merged)
- **Next Steps**: Phase 3 - Code quality improvements (DNS duplication, logging)

## Success Criteria
- ✅ No MAC address conflicts with multiple runners
- ✅ Correct network interface configuration
- ✅ Services start reliably on boot (Docker dependencies fixed)
- ✅ Error handling prevents broken containers
- 🔄 Runners connect to GitHub successfully
- 🔄 All integration tests pass
- 🔄 No DNS configuration conflicts

## Timeline
- ✅ Day 1-2: Critical bug fixes (COMPLETED - PR #23)
- ✅ Day 3-4: Service dependency fixes (COMPLETED - PR #24)
- 🔄 Week 2: Code quality improvements (NEXT)
- 🔄 Week 3: Full testing and documentation
- 🔄 Week 4: Performance optimizations