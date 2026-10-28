# Ansible standards

Decisions for Ansible in deployment repos, beneath the org [standards](https://github.com/junglestyle/.github/blob/main/code-standards/README.md), whose Deployment repos section says what such a repo holds. `.ansible-lint` holds the mechanical rules, such as full module names, `changed_when` on commands, and no `ignore_errors`; this file holds what it doesn't check.

## Layout

- `ansible.cfg` at the root sets the inventory and `roles_path`, and Galaxy installs into `./.collections`, which `.gitignore` lists.
- `site.yml` is the top-level playbook. Each playbook opens with a comment saying what it does and how to run it.
- Hosts and groups are in `inventory/hosts.yml`, and their values in `inventory/group_vars/` and `host_vars/`, not in playbooks.
- Repos share Ansible only as a collection listed in `requirements.yml`. No repo imports another's playbooks or roles by path.

## Tasks

- Use a module when one does the job. A `command` or `shell` task that bypasses one has a comment saying why the module won't do. `shell` is only for a pipe or a redirect.
- A precondition is an `ansible.builtin.assert` whose `fail_msg` says what's wrong and what fixes it.
- A service restarts only when something it reads has changed, through a handler or a registered result.
- A task whose arguments or result hold a secret sets `no_log: true`.

## Safety

- Every playbook is safe to rerun, and rerunning is how you upgrade. One that replaces something, such as a VM, says in its header what a rerun after a failure does.
- `--check --diff` changes nothing on the managed hosts and reports what a real run would. It may write scratch files on the controller, under the org's [Secrets](https://github.com/junglestyle/.github/blob/main/code-standards/README.md#secrets) rules when they hold one.
- A task that only reads sets `check_mode: false`, so check mode has its result. A task that can't be previewed is skipped with `when: not ansible_check_mode`, and no later task needs its result in check mode.
- Anything a playbook creates on shared ground, such as a VM, a dataset, or an app, carries a mark saying who made it. The playbook refuses to change or remove one without its mark.

## Checking

- `make check` runs `ansible-playbook --syntax-check` on each playbook and `ansible-lint`, with the collections from `requirements.yml` already installed. The syntax check turns off the sops vars plugin (`ANSIBLE_VARS_ENABLED=host_group_vars`), so it needs no key.
- `make check` runs ansible-core and ansible-lint through `uvx` at exact versions, so CI and the controller check with the same ones.
- Each repo's `.ansible-lint` starts as a copy of the org's [`.ansible-lint`](https://github.com/junglestyle/.github/blob/main/code-standards/.ansible-lint) and is the repo's to change after that. A rule it skips gets a comment saying why.

---

Drawn from the org's deployment repos, the [Ansible Lint rules](https://docs.ansible.com/projects/lint/rules/), and Ansible's [tips and tricks](https://docs.ansible.com/projects/ansible/latest/tips_tricks/ansible_tips_tricks.html), adapted.
