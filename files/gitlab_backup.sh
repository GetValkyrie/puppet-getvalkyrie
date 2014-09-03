#! /bin/sh

# This script copies data from the container's running environment to an
# internal data cache.

GITLAB_BACKUP_PATH=${GITLAB_BACKUP_PATH:=/container_data}

# Remove last cached data.
rm -rf $GITLAB_SOURCE_PATH/mysql
if [ -e $GITLAB_SOURCE_PATH/git ]; then
  rm -rf $GITLAB_SOURCE_PATH/git
fi
# Copy live data to our data cache.
cp /var/lib/mysql $GITLAB_SOURCE_PATH/mysql -r
if [ -e /home/git/repositories ]; then
  cp /home/git/repositories $GITLAB_SOURCE_PATH/git -r
fi
