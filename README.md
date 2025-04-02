
# 🛡️ Vault on AWS with Terraform

Este proyecto despliega HashiCorp Vault en AWS usando:
- EC2 con Docker
- Backend en S3 + KMS
- Auto-unseal
- Config inicial automática

## 📦 Estructura

```
vault-terraform/
├── main.tf
├── variables.tf
├── modules/
│   ├── ec2/
│   │   └── install_vault.sh.tmpl
│   ├── iam/
│   ├── kms/
│   ├── network/
│   └── s3/
├── Makefile
├── .gitignore
├── README.md
```

## 🚀 Comandos rápidos

```bash
make init       # Inicializa Terraform
make plan       # Muestra plan
make apply      # Aplica infraestructura
make destroy    # Destruye todo
```

## 🧪 Primer login

1. Vault se inicializa automáticamente
2. Claves guardadas en AWS Secrets Manager
3. Puedes hacer login como `admin / changeme123` tras correr `vault_bootstrap.sh`
