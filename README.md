# digital-summit25-demo

This was created to showcase Infrstructure as code using Terraform for the Digital Summit 2025

## instructions

- Setup AWS Access values
- Navigate to **terraform** folder.
- Firt time ran, run `terraform init` to setup required providers etc
- Run `terraform plan` to view Terraform changes
- Run `terraform deploy` to deploy the changes

> [!NOTE]  
> To run multiple instances, amend the provider s3.backend.key value to your own A account. then run `terraform init`.
