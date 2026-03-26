SHELL := /usr/bin/env bash

.PHONY: help init lint test validate terraform-fmt terraform-validate ansible-lint ansible-check smoke post-install-validate

help:
	@echo "Targets: init lint test validate terraform-fmt terraform-validate ansible-lint ansible-check smoke post-install-validate"

init:
	@chmod +x scripts/*.sh
	@python3 -m venv .venv
	@. .venv/bin/activate && pip install -U pip pytest pyyaml ansible-core

lint:
	@bash -n scripts/*.sh
	@python3 -m compileall tooling tests
	@./scripts/validate-config.sh

test:
	@pytest -q

terraform-fmt:
	@terraform -chdir=infra/terraform fmt -recursive

terraform-validate:
	@terraform -chdir=infra/terraform/environments/dev init -backend=false >/dev/null
	@terraform -chdir=infra/terraform/environments/dev validate
	@terraform -chdir=infra/terraform/environments/prod init -backend=false >/dev/null
	@terraform -chdir=infra/terraform/environments/prod validate

ansible-lint:
	@ANSIBLE_CONFIG=infra/ansible/ansible.cfg ansible-playbook --syntax-check -i infra/ansible/inventories/dev/hosts.yml infra/ansible/playbooks/site.yml

ansible-check: ansible-lint

validate: lint test

smoke:
	@./scripts/smoke-test.sh --target "$${TAK_FQDN:-localhost}" --insecure

post-install-validate:
	@./scripts/post-install-validate.sh --help
