# Ansible standards

Decisions for Ansible in deployment repos, beneath the org [standards](https://github.com/junglestyle/.github/blob/main/code-standards/README.md), whose Deployment repos section says what such a repo holds. `.ansible-lint` holds the mechanical rules; this file holds what a linter can't check.

## Layout

- `ansible.cfg` at the root sets the inventory and `roles_path`, and Galaxy installs into `./.collections`, which `.gitignore` lists.
- `site.yml` is the top-level playbook. Each playbook opens with a comment saying what it does and how to run it.
- Hosts and groups are in `inventory/hosts.yml`, and their values in `inventory/group_vars/` and `host_vars/`, not in playbooks.
- Tasks stay in the playbook until a second playbook needs them. Then they become a role.
- A role reads what it deploys as data, so adding another thing of the same kind needs no new Ansible.
- Repos share Ansible only as a collection, pinned by commit in `requirements.yml`. No repo imports another's playbooks or roles by path.
- `requirements.yml` pins every collection to an exact version or a commit.

## Tasks

- Call modules by their full name: `ansible.builtin.copy`, not `copy`.
- Prefer a module to `command`, and `command` to `shell`. `shell` is only for a pipe or a redirect.
- Each `command` or `shell` says when it changes something, with `creates`, `removes`, or `changed_when`. One that only reads has `changed_when: false`.
- No `ignore_errors`. A failure that's expected is spelled out with `failed_when`.
- A precondition is an `ansible.builtin.assert` whose `fail_msg` says what's wrong and what fixes it.
- A service restarts only when something it reads has changed, through a handler or a registered result.
- A task whose arguments or result hold a secret sets `no_log: true`.
- A role prefixes the variables it registers or sets with its own name, so a playbook that uses it can't collide with them.

## Safety

- Every playbook is safe to rerun, and rerunning is how you upgrade. One that replaces something, such as a VM, says in its header what a rerun after a failure does.
- `--check --diff` changes nothing and reports what a real run would. A task that only reads sets `check_mode: false`, so check mode has its result. A task that can't be previewed is skipped with `when: not ansible_check_mode`.
- Anything a playbook creates on shared ground, such as a VM, a dataset, or an app, carries a mark saying who made it. The playbook refuses to change or remove one without its mark.

## Checking

- `make check` runs `ansible-playbook --syntax-check` on each playbook and `ansible-lint`, with the collections from `requirements.yml` already installed. The syntax check turns off the sops vars plugin (`ANSIBLE_VARS_ENABLED=host_group_vars`), so it needs no key.
- ansible-core and ansible-lint run at exact versions, the same in CI as on the controller.
- Each repo's `.ansible-lint` starts as a copy of the org's [`.ansible-lint`](.ansible-lint) and is the repo's to change after that. A rule it skips gets a comment saying why.
- CI can't run `--check --diff`, since it needs the hosts and the key. Run it before every apply.

---

Drawn from the org's deployment repos, the [Ansible Lint rules](https://docs.ansible.com/projects/lint/rules/), and Ansible's [tips and tricks](https://docs.ansible.com/projects/ansible/latest/tips_tricks/ansible_tips_tricks.html), adapted.
