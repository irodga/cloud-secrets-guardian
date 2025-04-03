#!/bin/bash
set -e

VAULT_ADDR="https://127.0.0.1:8200"
VAULT_BIN="/usr/local/bin/vault"
INIT_FILE="/root/vault-init.json"

# Wait for Vault to start
echo "⏳ Esperando a que Vault esté listo..."
until curl -k --silent $VAULT_ADDR/v1/sys/health | grep -q "initialized"; do
  sleep 2
done

echo "✅ Vault está activo."

# Si ya fue inicializado, salir
if $VAULT_BIN status -address=$VAULT_ADDR | grep -q "Initialized.*true"; then
  echo "⚠️ Vault ya está inicializado. Saltando bootstrap."
  exit 0
fi

# Inicializar Vault
echo "🚀 Inicializando Vault..."
$VAULT_BIN operator init -format=json -address=$VAULT_ADDR > $INIT_FILE

# Extraer unseal keys y root token
UNSEAL_KEYS=$(jq -r '.unseal_keys_b64[]' $INIT_FILE)
ROOT_TOKEN=$(jq -r '.root_token' $INIT_FILE)

# Desellar
echo "🔓 Desellando Vault..."
COUNT=0
for key in $UNSEAL_KEYS; do
  $VAULT_BIN operator unseal -address=$VAULT_ADDR $key
  COUNT=$((COUNT+1))
  if [ $COUNT -ge 3 ]; then
    break
  fi
done

# Guardar token para Terraform
echo "🔑 Exportando VAULT_TOKEN..."
echo "export VAULT_TOKEN=${ROOT_TOKEN}" >> /etc/profile.d/vault.sh
chmod +x /etc/profile.d/vault.sh

echo "✅ Vault inicializado y desellado."
