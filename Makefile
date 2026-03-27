SHELL := /usr/bin/env bash

.PHONY: help init validate lint test terraform-fmt terraform-validate ansible-lint ansible-check smoke

help:
	@echo "Available targets: init validate lint test terraform-fmt terraform-validate ansible-lint ansible-check smoke"

init:
	@chmod +x scripts/*.sh
	@python3 -m venv .venv
	@. .venv/bin/activate && pip install -U pip pytest PyYAML ansible

validate: terraform-fmt terraform-validate lint test ansible-lint

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

smoke:
	@./scripts/smoke-test.sh
