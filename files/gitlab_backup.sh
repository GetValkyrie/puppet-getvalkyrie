#! /bin/sh

# This script copies data from the container's running environment to an
# internal data cache.

GITLAB_BACKUP_PATH=${GITLAB_BACKUP_PATH:=/container_data}

# Initialize backup path, if it doesn't already exist
if [ ! -e $GITLAB_BACKUP_PATH/mysql ]; then
  mkdir -p $GITLAB_BACKUP_PATH/mysql
fi
if [ ! -e $GITLAB_BACKUP_PATH/git ]; then
  mkdir -p $GITLAB_BACKUP_PATH/git
fi

# Remove existing cached data.
if [ -e $GITLAB_BACKUP_PATH/mysql ]; then
  rm -rf $GITLAB_BACKUP_PATH/mysql
fi
if [ -e $GITLAB_BACKUP_PATH/git ]; then
  rm -rf $GITLAB_BACKUP_PATH/git
fi

# Copy live data to our data cache.
cp /var/lib/mysql $GITLAB_BACKUP_PATH/mysql -r
if [ -e /home/git/repositories ]; then
  cp /home/git/repositories $GITLAB_BACKUP_PATH/git -r
fi

