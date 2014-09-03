#! /bin/sh

# This script copies data from the container's internal data cache to the
# appropriate locations for use by GitLab. To allow for initializing the data
# cache from a mounted volume, we use an environmental variable (but provide a
# default).

GITLAB_BACKUP_PATH=${GITLAB_BACKUP_PATH:=/container_data}

# Move current data out of the way.
mv /var/lib/mysql /var/lib/mysql.`date --iso-8601=seconds`
if [ -e /home/git/repositories ]; then
  mv /home/git/repositories /home/git/repositories.`date --iso-8601=seconds`
fi
# Copy our cached data into place.
cp $GITLAB_SOURCE_PATH/mysql /var/lib/mysql -r
if [ -e $GITLAB_SOURCE_PATH/git ]; then
  cp $GITLAB_SOURCE_PATH/git /home/git/repositories -r
fi
