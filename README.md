# MediShop Todo — Projet DevOps complet

Application Todo 3 tiers déployée sur AWS avec Terraform, Ansible, Docker, Nginx et GitHub Actions.

## Architecture

- **Front EC2** dans un sous-réseau public : Nginx système + conteneur React/Nginx
- **Back EC2** dans un sous-réseau privé : API Node.js/Express
- **DB EC2** dans un sous-réseau privé : PostgreSQL
- Accès SSH au Back et à la DB via le Front en tant que bastion
- Security Groups : Internet → Front, Front → Back, Back → DB uniquement
- NAT Gateway optionnelle mais activée par défaut pour permettre aux instances privées d'installer Docker et de tirer les images

> Attention : la NAT Gateway et les Elastic IP peuvent générer des frais AWS. Pour un TP, détruisez l'infrastructure après démonstration.

## Arborescence

- `terraform/` : VPC, sous-réseaux, routage, NAT, EC2, Security Groups
- `ansible/` : installation Docker, Nginx, déploiement des services
- `frontend/` : React + Vite
- `backend/` : Node.js + Express + PostgreSQL
- `nginx/` : reverse proxy et HTTPS
- `.github/workflows/` : CI/CD
- `deploy/` : scripts de déploiement avec rollback

## Prérequis

- AWS CLI configuré
- Terraform >= 1.6
- Ansible >= 2.15
- Une paire de clés EC2 existante dans AWS
- Docker Hub ou GHCR
- Un nom de domaine pointant vers l'IP publique du Front

## 1. Infrastructure Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Modifier les valeurs
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

Sorties :

```bash
terraform output
```

## 2. Générer l'inventaire Ansible

```bash
cd ../ansible
../terraform/generate_inventory.sh
```

## 3. Configurer les variables Ansible

```bash
cp group_vars/all.yml.example group_vars/all.yml
ansible-vault create group_vars/all/vault.yml
```

Exemple du contenu chiffré :

```yaml
vault_db_password: "mot-de-passe-fort"
vault_registry_username: "mon-compte"
vault_registry_password: "mon-token"
```

## 4. Provisionner les serveurs

```bash
ansible-playbook -i inventory.ini site.yml --ask-vault-pass
```

## 5. Déploiement local manuel

Le playbook lance les conteneurs avec les images configurées dans `group_vars/all.yml`.

## 6. Secrets GitHub Actions

Ajouter dans le dépôt :

- `REGISTRY_USERNAME`
- `REGISTRY_PASSWORD`
- `REGISTRY_HOST` — ex. `docker.io`
- `FRONT_IMAGE` — ex. `moncompte/medishop-front`
- `BACK_IMAGE` — ex. `moncompte/medishop-back`
- `SSH_PRIVATE_KEY`
- `SSH_USER` — ex. `ubuntu`
- `FRONT_HOST`
- `BACK_PRIVATE_IP`
- `DB_PRIVATE_IP`
- `DB_NAME`
- `DB_USER`
- `DB_PASSWORD`
- `DOMAIN_NAME`

Le workflow détecte les changements Front/Back, construit et pousse seulement les images concernées, puis déploie par SSH. Le déploiement Back passe par le Front avec `ProxyJump`.

## 7. HTTPS

Après que le DNS pointe vers le Front :

```bash
sudo certbot --nginx -d todo.example.com --non-interactive --agree-tos -m admin@example.com
```

## 8. Détruire l'infrastructure

```bash
cd terraform
terraform destroy
```

## Tests rapides

```bash
curl http://<FRONT_IP>/api/health
curl http://<FRONT_IP>/api/todos
```
