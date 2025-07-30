# Cursor Rules for NAS Infrastructure Project

This directory contains Cursor rules that align with the project's structure and practices.
These rules help maintain consistency and quality across the codebase.

## Rule Files

### `ansible.mdc`

Comprehensive rules for Ansible playbooks, roles, and tasks. Covers:

- Role structure standards
- Naming conventions
- Task guidelines
- Variable management
- Security practices
- Linting compliance
- Pre-commit integration

### `terraform.mdc`

Rules for Terraform infrastructure code. Includes:

- Module structure standards
- Naming conventions
- Variable management
- Security practices
- Linting compliance
- Pre-commit integration

### `yaml.mdc`

YAML formatting and structure rules. Covers:

- Formatting standards
- YAML structure
- Ansible-specific guidelines
- Security considerations
- Linting compliance

### `markdown.mdc`

Documentation formatting rules. Includes:

- Header structure
- Code blocks
- Links and references
- Project-specific guidelines
- Validation requirements

### `pre-commit.mdc`

Pre-commit hook configuration and usage. Covers:

- Hook configuration
- File checks
- Linting tools
- Security scanning
- Integration guidelines

### `security.mdc`

Security best practices and guidelines. Includes:

- Secret management
- Access control
- Network security
- Infrastructure security
- Compliance requirements

### `general.mdc`

General development practices. Covers:

- Project structure
- File organization
- Version control
- Documentation
- Quality assurance

## Usage

These rules are automatically applied by Cursor when editing files in the project. The rules are designed to:

1. **Maintain Consistency**: Ensure all code follows established patterns
2. **Enforce Best Practices**: Apply industry-standard practices
3. **Improve Quality**: Catch issues early through linting and validation
4. **Enhance Security**: Prevent common security issues
5. **Streamline Development**: Provide clear guidelines for contributors

## Integration with Project Tools

These rules align with the project's existing tools:

- **Pre-commit hooks**: Rules complement the `.pre-commit-config.yaml` configuration
- **Linting tools**: Rules follow `.ansible-lint`, `.yamllint`, `.tflint.hcl` configurations
- **Security tools**: Rules integrate with `gitleaks` and other security scanning
- **Documentation**: Rules support `.markdownlint.json` formatting standards

## Customization

To customize these rules for your specific needs:

1. Edit the appropriate `.mdc` file
2. Add project-specific patterns or requirements
3. Update the rules to match your team's preferences
4. Test the changes to ensure they work as expected

## Best Practices

When using these rules:

1. **Follow the Guidelines**: Apply the rules consistently across all files
2. **Use the Tools**: Leverage the integrated linting and validation tools
3. **Maintain Quality**: Use the rules to catch issues early
4. **Document Changes**: Update rules when project requirements change
5. **Review Regularly**: Periodically review and update rules as needed

## Support

For questions about these rules or to suggest improvements:

1. Review the existing rule files for guidance
2. Check the project's documentation for additional context
3. Consult the team for project-specific requirements
4. Update rules based on lessons learned and best practices

## Related Files

These rules work in conjunction with:

- `.pre-commit-config.yaml`: Pre-commit hook configuration
- `.ansible-lint`: Ansible linting rules
- `.yamllint`: YAML linting configuration
- `.tflint.hcl`: Terraform linting rules
- `.markdownlint.json`: Markdown linting configuration
- `.gitleaks.toml`: Secret detection configuration

The rules are designed to complement these existing configurations and provide additional guidance for development practices.
