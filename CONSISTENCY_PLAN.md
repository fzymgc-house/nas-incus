# Codebase Consistency Improvement Plan

## Overview
This document outlines the plan to fix identified inconsistencies in the NAS infrastructure codebase. The plan is organized by priority phases and will be updated as steps are completed.

## Phase 1: Code Style Standardization (High Priority)

### 1. Standardize YAML Boolean Values
- **Status**: ⏳ Pending
- **Issue**: Mixed `yes`/`no` vs `true`/`false` usage
- **Fix**: Convert all boolean values to `true`/`false` format
- **Files**: All playbooks (`*.yml`) and role task files
- **Impact**: Improves consistency and follows modern Ansible best practices

### 2. Standardize Handler Naming
- **Status**: ⏳ Pending
- **Issue**: Mixed case patterns (`restart caddy` vs `Restart systemd-resolved`)
- **Fix**: Adopt consistent `Restart <service>` pattern with proper capitalization
- **Files**: All `handlers/main.yml` files across roles
- **Impact**: Consistent handler naming across all roles

### 3. Standardize File Mode Specifications
- **Status**: ⏳ Pending
- **Issue**: Mixed quoted/unquoted file modes (`"0644"` vs `0755`)
- **Fix**: Use consistent quoted format `"0644"` for all file modes
- **Files**: All task files with file operations
- **Impact**: Prevents potential parsing issues and improves readability

## Phase 2: Variable and Configuration Consistency (Medium Priority)

### 4. Standardize OnePassword Lookup Patterns
- **Status**: ⏳ Pending
- **Issue**: Inconsistent vault specifications and field naming
- **Fix**: Establish consistent pattern with explicit vault names for lookups **NOTE: Do not change any paths in 1Password itself - only standardize the lookup syntax**
- **Files**: All playbooks and task files using OnePassword lookups
- **Impact**: Improves security consistency and reduces errors

### 5. Normalize Variable Naming and Organization
- **Status**: ⏳ Pending
- **Issue**: Mixed placement of variables (defaults vs vars) and naming patterns
- **Fix**: Move role-specific defaults to `defaults/main.yml`, keep environment-specific values in `vars/`
- **Files**: All role `defaults/` and `vars/` directories
- **Impact**: Clearer variable precedence and better role reusability

## Phase 3: Role Structure Standardization (Medium Priority)

### 6. Complete Role Directory Structure
- **Status**: ⏳ Pending
- **Issue**: Missing standard directories (`defaults/`, `meta/`, `templates/`) in some roles
- **Fix**: Create missing directories and files for consistent structure
- **Files**: `common/`, `caddy/`, and other incomplete roles
- **Impact**: Consistent role structure and better maintainability

### 7. Add Missing Role Documentation
- **Status**: ⏳ Pending
- **Issue**: Most roles lack README files
- **Fix**: Create README.md files for all custom roles with usage examples
- **Files**: All roles in `roles/` directory
- **Impact**: Better documentation and easier onboarding

## Phase 4: Template and Configuration Normalization (Low Priority)

### 8. Standardize Template Delimiters
- **Status**: ⏳ Pending
- **Issue**: Mixed custom vs standard Jinja2 delimiters
- **Fix**: Evaluate necessity of custom delimiters, standardize where possible
- **Files**: `app-proxy-caddy` role templates and tasks
- **Impact**: Easier template maintenance and consistency

### 9. Normalize Package Variable Names
- **Status**: ⏳ Pending
- **Issue**: Same variable names (`packages_to_install`) used across different roles
- **Fix**: Use role-prefixed variable names (`caddy_packages_to_install`)
- **Files**: Role `vars/main.yml` files
- **Impact**: Prevents variable conflicts and improves clarity

## Phase 5: Advanced Consistency Improvements (Low Priority)

### 10. Standardize Service Management Patterns
- **Status**: ⏳ Pending
- **Issue**: Mixed service module usage (`ansible.builtin.service` vs `ansible.builtin.systemd`)
- **Fix**: Use `ansible.builtin.systemd` consistently for systemd services
- **Files**: All handler files and service management tasks
- **Impact**: Consistent service management approach

### 11. Normalize Tag Naming Strategy
- **Status**: ⏳ Pending
- **Issue**: Mixed granularity and naming patterns for tags
- **Fix**: Establish consistent tag taxonomy (service-level, infrastructure-level)
- **Files**: All playbooks and task files with tags
- **Impact**: Better selective execution and organization

## Implementation Guidelines

### Prerequisites
- **Clean Working Directory**: Before starting any new phase, ensure the working directory is clean with `git status` showing no uncommitted changes
- **Commit Current Work**: If there are existing changes, commit them first to isolate consistency fixes from other work
- **Branch Strategy**: Consider creating a dedicated branch for consistency improvements

### Priority Order
1. **High Priority (Phase 1)**: Critical for code maintainability and preventing issues
2. **Medium Priority (Phases 2-3)**: Important for consistency and documentation
3. **Low Priority (Phases 4-5)**: Nice-to-have improvements for long-term maintainability

### Status Legend
- ⏳ Pending
- 🔄 In Progress
- ✅ Completed
- ❌ Blocked
- 📝 Needs Review

### Notes Section
- **Important**: For step 4 (OnePassword standardization), do not modify any paths in 1Password itself - only standardize the lookup syntax in the Ansible code
- Each completed step should be marked with completion date and any relevant notes
- If issues are encountered, document them in this section

## Progress Tracking
- Plan created: [Date]
- Last updated: [Date]
- Overall progress: 0/11 items completed

## Next Steps
1. Begin with Phase 1 items (highest priority)
2. Test changes in development environment before applying to production
3. Update this plan as items are completed
4. Document any deviations or issues encountered