#!/usr/bin/env bash
set -euo pipefail
TF_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT="$TF_DIR/../ansible/inventory.ini"
FRONT=$(terraform -chdir="$TF_DIR" output -raw front_public_ip)
BACK=$(terraform -chdir="$TF_DIR" output -raw back_private_ip)
DB=$(terraform -chdir="$TF_DIR" output -raw db_private_ip)
cat > "$OUT" <<EOT
[front]
front1 ansible_host=$FRONT

[back]
back1 ansible_host=$BACK

[db]
db1 ansible_host=$DB

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/medishop-key.pem
ansible_python_interpreter=/usr/bin/python3

[private:children]
back
db

[private:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -i ~/.ssh/medishop-key.pem -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -W %h:%p ubuntu@$FRONT" -o StrictHostKeyChecking=no -o IdentitiesOnly=yes'
EOT
echo "Inventaire généré : $OUT"
