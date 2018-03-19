#!/bin/bash
#
## Script bash de sauvegarde de blogs WordPress vers un serveur Nextcloud
#
#Pour plus d'infos : https://memo-linux.com/script-de-sauvegarde-wordpress-vers-nextcloud/
#
##Initialiser les variables
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
user=USER_MariaDB
mdp=MDP_USER_MariaDB
backupdate=$(date +%Y-%m-%d)
backupdir=/home/fred/nextcloud/backup/

##suppression des sauvegardes de bases de données vielles de +3 jours
find  "$backupdir"/bdd -type f -mtime +3 -delete

##sauvegarde des bases de données compressées avec bzip2
while read -r database
do 
mysqldump -u"$user" -p"$mdp" "$database" | bzip2 -c > "$backupdir"/bdd/"$database"_"$backupdate".sql.bz2
done < bdd.txt

##rsync wordpress
while read -r site
do
rsync -avz --progress --delete --exclude wp-content/cache/ --stats /var/www/"$site"/ "$backupdir"/"$site"/
done < site.txt

##synchro vers nextcloud
nextcloudcmd "$backupdir" https://User_Nextcloud:MDP_User_Nextcloud@nextcloud.domaine.tld/remote.php/webdav/
##une fois fini on s'envoie un mail avec la liste des bdd par exemple
ls -1 "$backupdir"/bdd/ > /var/log/sauv_wp.log
mail -s Sauv_WP user@domaine.tld < /var/log/sauv_wp.log
