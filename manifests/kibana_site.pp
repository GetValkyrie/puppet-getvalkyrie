# class: getvalkyrie::kibana_site
#
# Install Kibana at the specified version.
class getvalkyrie::kibana_site (
  $version = 'v3.1.0',
) {

  $kibana_dir = '/usr/share/kibana3'

  package {'git': before => Vcsrepo[$kibana_dir] }

  vcsrepo { $kibana_dir:
    ensure   => present,
    provider => git,
    source   => 'https://github.com/elasticsearch/kibana.git',
    revision => $version,
#    user     => 'www-data',
  }

  class { 'kibana3':
    elasticsearch_host  => '127.0.0.1',
    elasticsearch_index => 'kibana-int',
    elasticsearch_port  => '9200',
    service_name        => 'supervisor::nginx',
    pkg_ensure          => absent,
    require             => [
      Vcsrepo[$kibana_dir],
      Supervisor::Service['nginx'],
    ]
  }

  # Add a dummy service here (already installed by the nginx baseimage), so
  # that the Kibana install knows how to restart nginx.
  class { 'nginx': }
  supervisor::service {'nginx':
    ensure  => present,
    command => '/usr/sbin/nginx',
  }

  nginx::resource::vhost { 'default':
    www_root => "${kibana_dir}/src",
    require  => [
      Class['kibana3'],
      Vcsrepo[$kibana_dir],
    ]
  }

}
