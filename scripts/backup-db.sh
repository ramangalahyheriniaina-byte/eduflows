#!/bin/bash

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/eduflows_db_$TIMESTAMP.sql"

mkdir -p $BACKUP_DIR

echo "💾 Backup de la base de données..."
docker-compose exec -T postgres pg_dump -U eduflows_user eduflows_db > $BACKUP_FILE

echo "✅ Backup sauvegardé: $BACKUP_FILE"
echo "📊 Taille: $(du -h $BACKUP_FILE | cut -f1)"
