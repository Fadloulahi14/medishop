.PHONY: local-up local-down tf-init tf-plan tf-apply tf-destroy inventory provision
local-up:
	docker compose -f docker-compose.local.yml up --build
local-down:
	docker compose -f docker-compose.local.yml down -v
tf-init:
	terraform -chdir=terraform init
tf-plan:
	terraform -chdir=terraform plan
tf-apply:
	terraform -chdir=terraform apply
tf-destroy:
	terraform -chdir=terraform destroy
inventory:
	./terraform/generate_inventory.sh
provision:
	cd ansible && ansible-galaxy collection install -r requirements.yml && ansible-playbook site.yml --ask-vault-pass
