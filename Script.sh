#!/bin/bash

# Configuration
ftp_server="192.168.20.141"
ftp_user="user"
ftp_password="user"
ftp_remote_dir="/"  # Remplacez par le répertoire distant approprié

# Chemin du fichier log
log_path="/var/www/html/nextcloud/data/nextcloud.log"

# Chemin de sauvegarde local
local_backup_dir="/home/user/archive"
log_filename="sio2-$(date +%d-%m-%Y_%H:%M:%S)"

# Vérification si le dossier de sauvegarde local existe, sinon le créer
mkdir -p "$local_backup_dir"

# Sauvegarde locale du fichier log
if cp "$log_path" "$local_backup_dir/$log_filename.log"; then
    echo "Sauvegarde locale réussie : $local_backup_dir/$log_filename.log"
else
    echo "Échec de la sauvegarde locale."
    exit 1
fi

# Compression du fichier log avec tar et gzip
if tar -czf "$local_backup_dir/$log_filename.tar.gz" -C "$local_backup_dir" "$log_filename.log"; then
    echo "Compression réussie : $local_backup_dir/$log_filename.tar.gz"
else
    echo "Échec de la compression."
    exit 1
fi

# Transfert vers le serveur FTP
if ftp -n $ftp_server <<EOF
user $ftp_user $ftp_password
cd "$ftp_remote_dir"
put "$local_backup_dir/$log_filename.tar.gz" "$log_filename.tar.gz"
bye
EOF
then
    echo "Transfert FTP réussi : $log_filename.tar.gz"
else
    echo "Échec du transfert FTP."
    exit 1
fi
