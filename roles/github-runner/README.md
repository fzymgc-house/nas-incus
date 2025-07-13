# GitHub Runner Ansible Role

This role installs and configures GitHub Actions self-hosted runners on Ubuntu systems.

## Requirements

- Ubuntu 20.04 or later
- Docker pre-installed (handled by cloud-init)
- Runner user already created (handled by cloud-init)
- GitHub organization or repository access
- GitHub Personal Access Token (PAT) or registration token

## Role Variables

### Required Variables

- `github_runner_registration_token`: Registration token for the runner (from GitHub settings)
- Either `github_runner_org` OR `github_runner_repo`: Organization or repository to register with

### Optional Variables

```yaml
# Runner version
github_runner_version: "2.321.0"

# Runner name (defaults to inventory hostname)
github_runner_name: "{{ inventory_hostname }}"

# Runner labels
github_runner_labels: "self-hosted,Linux,X64,docker"

# Allow auto-updates
github_runner_allow_update: true

# Additional packages to install
github_runner_packages_to_install: []
```

## Dependencies

- `common` role (for base system configuration)

## Example Playbook

```yaml
- hosts: github_runners
  vars:
    github_runner_org: "my-organization"
    github_runner_registration_token: "{{ lookup('onepassword', 'GitHub Runner Token', field='token') }}"
  roles:
    - github-runner
```

## Example with Repository Runner

```yaml
- hosts: github_runners
  vars:
    github_runner_repo: "my-org/my-repo"
    github_runner_registration_token: "{{ lookup('onepassword', 'GitHub Runner Token', field='token') }}"
    github_runner_labels: "self-hosted,Linux,X64,docker,gpu"
  roles:
    - github-runner
```

## 1Password Integration

Store your GitHub runner registration token in 1Password:

1. Create an item named "GitHub Runner Token"
2. Add a field named "token" with the registration token
3. Reference it in your playbook or inventory

## Service Management

The role creates a systemd service named `github-runner` that:

- Starts automatically on boot
- Restarts on failure
- Runs as the `runner` user
- Has appropriate security restrictions
- Supports auto-updates (if enabled)

## Directory Structure

- `/home/runner/actions-runner`: Runner installation directory
- `/home/runner/workspace`: Runner work directory

## Security Considerations

- Runner runs as non-root user
- Service has restricted permissions (ProtectSystem, PrivateTmp)
- No new privileges can be gained
- Limited filesystem access

## Troubleshooting

Check runner status:
```bash
systemctl status github-runner
```

View runner logs:
```bash
journalctl -u github-runner -f
```

Manually configure runner:
```bash
sudo -u runner /home/runner/actions-runner/config.sh
```

## License

MIT