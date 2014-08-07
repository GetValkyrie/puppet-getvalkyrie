# class: getvalkyrie::gitlab_base
#
# Install and configure the requirements for gitlab.
class getvalkyrie::gitlab_base {

  #include getvalkyrie::gitlab_packages
  #include git
  #include logrotate

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
#    before  => Class['::gitlab'],
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
#    before  => Class['::gitlab'],
  }
/*
  anchor { 'gitlab_requirements::begin': }
  anchor { 'gitlab_requirements::end': }

  Anchor['gitlab_requirements::begin'] ->
  Class['logrotate'] ->
  Class['git'] ->
  Mysql::Db[$gitlab_dbname] ->
  Supervisor::Service['mysqld']->
  Supervisor::Service['redis-server']->
  Anchor['gitlab_requirements::end']
*/
}

