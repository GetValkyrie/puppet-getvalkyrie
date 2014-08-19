# class: getvalkyrie::gitlab
#
# Install and configure gitlab.
class getvalkyrie::gitlab {

  # We should move this to trocla, or something.
  $gitlab_dbname = 'gitlab_db'
  $gitlab_dbpwd = 'gitlab_dbpwd'
  $gitlab_dbuser = 'gitlab_dbuser'

  class {
    '::gitlab':
      git_user            => 'git',
      git_home            => '/home/git',
      gitlab_repodir      => '/home/git/repos'
      git_email           => 'chris@ergonlogic.com',
      git_comment         => 'GitLab',
      gitlab_sources      => 'https://github.com/gitlabhq/gitlabhq.git',
      #gitlab_branch       => '7-1-stable',
      gitlab_domain       => 'localhost',
      #gitlab_domain       => 'git.getvalkyrie.com',
      gitlab_http_timeout => '300',
      # BACKUPS: Keep full backups for 30 days
      gitlab_backup       => true,
      gitlab_backup_path  => 'backups',
      gitlab_backup_keep_time => '2592000',
      # DATABASE: Move to Postgresql
      gitlab_dbname       => $gitlab_dbname,
      gitlab_dbuser       => $gitlab_dbuser,
      gitlab_dbpwd        => $gitlab_dbpwd,
      ldap_enabled        => false,
      gitlab_dbtype       => 'mysql',
      #gitlab_dbtype     => 'pgsql',
      #require           => Postgresql::Server::Db[$gitlab_dbname],
  }

# export and mount db data volume
# mount git data volume
# mount gitlab backups volume (on s3 w/ s3fs?)


  $unicorn_path = '/opt/unicorn.sh'
  file { $unicorn_path :
    ensure  => file,
    #source  => 'puppet:///modules/getvalkyrie/unicorn.sh',
    content => "#!/bin/bash
rm -f /home/git/gitlab/tmp/sockets/gitlab.socket
bundle exec unicorn_rails -c config/unicorn.rb -E production",
    owner   => 'git',
    mode    => 700,
    require => Class['::gitlab'],
  }
  supervisor::service { 'unicorn':
    ensure    => running,
    command   => $unicorn_path,
    user      => 'git',
    directory => '/home/git/gitlab',
    require   => File[$unicorn_path],
  }
  supervisor::service { 'sidekiq':
    ensure    => running,
    command   => 'bundle exec sidekiq -q post_receive -q mailer -q system_hook -q project_web_hook -q gitlab_shell -q common -q default -e production',
    user      => 'git',
    directory => '/home/git/gitlab',
    require   => Class['::gitlab'],
  }

  file { '/etc/nginx/conf.d/default.conf':
    ensure => absent,
    before => Supervisor::Service['nginx']
  }
  exec { '/bin/echo "daemon off;" >> /etc/nginx/nginx.conf':
    unless => "/bin/grep 'daemon off;' /etc/nginx/nginx.conf",
    before => Supervisor::Service['nginx']
  }
  supervisor::service { 'nginx':
    ensure  => present,
    command => '/usr/sbin/nginx',
    require => Class['::gitlab'],
  }

}
