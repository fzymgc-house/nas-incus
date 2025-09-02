### Role: nas-container-users

Manage groups and users on `nas-container-apps` hosts, supporting explicit GIDs and UIDs.

#### Variables

- `nas_container_groups`: list of groups to manage
- `nas_container_users`: list of users to manage

#### Group item structure

```yaml
nas_container_groups:
  - name: media
    gid: 1001            # optional
    state: present       # optional, default: present
    system: false        # optional
```

#### User item structure

```yaml
nas_container_users:
  - name: radarr
    uid: 2001              # optional
    group: media           # optional primary group (must exist)
    groups: [docker]       # optional supplemental groups
    append: true           # optional, default: true
    comment: Radarr user   # optional
    shell: /usr/sbin/nologin  # optional
    home: /nonexistent     # optional
    create_home: false     # optional
    state: present         # optional, default: present
    system: false          # optional
    password: '...'        # optional, already-hashed string
    remove: false          # optional, when state: absent
    ssh_authorized_keys:   # optional list of SSH public keys
      - ssh-ed25519 AAAA... user@example
```

#### Usage

Add variables in inventory (e.g., `inventory/group_vars/production.yml` or host vars) and include the role in your play:

```yaml
- hosts: nas-container-apps
  become: true
  roles:
    - role: nas-container-users
```
