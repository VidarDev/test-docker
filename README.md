# Infrastructure PrestaShop Docker - Production Ready

## Installation

1. Cloner le dépôt :

2. Copier et configurer le fichier d'environnement :

```bash
cp .env.example .env
```

3. Créer les répertoires pour les secrets :

```bash
mkdir -p secrets && \
echo "motdepasseroot" > secrets/mysql_root_password.txt && \
echo "motdepasseprestashop" > secrets/mysql_prestashop_password.txt && \
chmod 600 secrets/*.txt
```

4. Lancer l'infrastructure :

```bash
docker-compose up -d
```

5. Vérifier que tous les services fonctionnent correctement :

```bash
docker-compose ps
```
