# class: getvalkyrie::gitlab_base
#
# Install and configure the requirements for gitlab.
#
# N.B. This class assume that getvalkyrie::gitlab_packages has already run to
# install basic packages.
class getvalkyrie::gitlab_base {

  include logrotate

  user { 'git':
    # The gitlab user (git) needs to be able to write to the postdrop directory
    # in order to send emails.
    groups => 'postdrop',
  }
  supervisor::service { 'postfix':
    ensure       => 'running',
    process_name => 'master',
    autorestart  => false,
    startsecs    => 0,
    directory    => '/etc/postfix',
    command      => '/usr/sbin/postfix -c /etc/postfix start',
  }

  class { 'redis':
    service_enable  => false,
    service_ensure  => 'stopped',
    service_restart => false,
  }
  exec { "/bin/sed -e '/^daemonize/ s/^#*/#/' -i /etc/redis/redis.conf":
    require => Class['redis'],
    before  => Supervisor::Service['redis-server'],
  }
  supervisor::service { 'redis-server':
    ensure  => 'running',
    command => '/usr/bin/redis-server /etc/redis/redis.conf',
  }

  class { 'mysql::server':
    service_manage  => false,
    service_enabled => false,
  }
  $gitlab_dbname = 'gitlab_db'
  $gitlab_dbpwd = 'gitlab_dbpwd'
  $gitlab_dbuser = 'gitlab_dbuser'
  mysql::db { $gitlab_dbname :
    user     => $gitlab_dbuser,
    password => $gitlab_dbpwd,
    require  => Class['mysql::server'],
  }
  supervisor::service { 'mysqld':
    ensure  => 'running',
    command => '/usr/sbin/mysqld',
    require => Mysql::Db[$gitlab_dbname],
  }

}
