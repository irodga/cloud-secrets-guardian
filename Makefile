
.PHONY: init plan apply destroy clean

init:
	terraform init

plan:
	terraform plan

apply:
	terraform apply -auto-approve

destroy:
	terraform destroy -auto-approve

clean:
	rm -rf .terraform terraform.tfstate terraform.tfstate.backup .terraform.lock.hcl
