#! /bin/sh

# This script copies data from the container's internal data cache to the
# appropriate locations for use by GitLab. To allow for initializing the data
# cache from a mounted volume, we use an environmental variable (but provide a
# default).

GITLAB_BACKUP_PATH=${GITLAB_BACKUP_PATH:=/container_data}
CURRENT_TIME=`date --iso-8601=seconds`

# Move current data out of the way.
mkdir /var/lib/mysql.$CURRENT_TIME
mv /var/lib/mysql/* /var/lib/mysql.$CURRENT_TIME/
if [ -e /home/git/repositories ]; then
  mkdir /home/git/repositories.$CURRENT_TIME
  mv /home/git/repositories/* /home/git/repositories.$CURRENT_TIME/
fi
# Copy our cached data into place.
cp $GITLAB_BACKUP_PATH/mysql/* /var/lib/mysql/ -r
if [ -e $GITLAB_BACKUP_PATH/git ]; then
  cp $GITLAB_BACKUP_PATH/git/* /home/git/repositories/ -r
fi

