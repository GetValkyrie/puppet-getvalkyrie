# class: getvalkyrie::gitlab_data
#
# Create a data-only container using data from gitlab image build.
#
# The purpose of this container is to initialize mounted volumes with MySQL
# data, which is in turn mounted from a gitlab container via '--volumes-from'.
# It also provides a script to copy 'live' data (from the volume) back over that
# stored in the container. This allows the container to be exported, and thus
# moved to a new docker host as an image.
#
# N.B. This image assumes that the gitlab_packages, gitlab_base and gitlab
# images have already been built on this host, since they provide the required
# seed data.
class getvalkyrie::gitlab_data (
){

  # Script to copy data from mounted volumes to container (backup).
  file { '/root/gitlab_backup.sh':
    source => 'puppet:///modules/getvalkyrie/gitlab_backup.sh',
    mode   => 700,
  }

  # Script to copy data from container to mounted volumes (restore).
  file { '/root/gitlab_restore.sh':
    source => 'puppet:///modules/getvalkyrie/gitlab_restore.sh',
    mode   => 700,
  }

  # Initialize container data
/*  exec { 'Seed container data from mounted volume':
    command     => '/root/gitlab_backup.sh',
    environment => ["GITLAB_BACKUP_PATH=${volume_path}"],
    require     => File['/root/gitlab_restore.sh'],
  }*/
  exec { 'Backup data in container (for image export)':
    command => '/root/gitlab_backup.sh',
    require => [
       File['/root/gitlab_backup.sh'],
#       Exec['Seed container data from mounted volume'],
    ],
  }

}
