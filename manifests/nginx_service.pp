# class: getvalkyrie::nginx_service
#
# Install and configure nginx.
class getvalkyrie::nginx_service {

  class { 'nginx': }

  # Ensure nginx runs in the foreground.
  exec { '/bin/echo "daemon off;" >> /etc/nginx/nginx.conf':
    unless  => "/bin/grep 'daemon off;' /etc/nginx/nginx.conf",
    before  => Supervisor::Service['nginx'],
    require => Class['nginx']
  }

  file { '/etc/nginx/conf.d/default.conf':
    ensure => absent,
    require => Class['nginx'],
    before  => Supervisor::Service['nginx'],
  }

  supervisor::service { 'nginx':
    ensure  => present,
    command => '/usr/sbin/nginx',
    require => Class['nginx'];
  }

}
