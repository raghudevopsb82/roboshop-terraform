dev-apply:
	git pull
	terraform init -backend-config=./env-dev/state.tfvars
	terrafrom apply -auto-approve -var-file=env-dev/main.tfvars

prod-apply:
	git pull
	terraform init -backend-config=./env-prod/state.tfvars
	terrafrom apply -auto-approve -var-file=env-prod/main.tfvars

