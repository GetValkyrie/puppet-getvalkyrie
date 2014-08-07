# class: getvalkyrie::elasticsearch_service
#
# Install elasticsearch at the specified version.
class getvalkyrie::elasticsearch_service (
  $version = '1.3.1',
) {

  $elasticsearch_deb_url = "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-${version}.deb"
  $elasticsearch_deb_path = "/tmp/cache/elasticsearch-${version}.deb"

  wget::fetch { $elasticsearch_deb_url:
    destination => $elasticsearch_deb_path,
#    cache_dir   => '/tmp/cache',
    verbose     => true,
  }

  # Install Elasticsearch from the .deb packages we fetched.
  class { 'elasticsearch':
    package_url => "file:${elasticsearch_deb_path}",
    require     => Wget::Fetch[$elasticsearch_deb_url],
  }

  supervisor::service { 'elasticsearch':
    ensure  => present,
    command => '/usr/share/elasticsearch/bin/elasticsearch -f',
    require => Class['elasticsearch'];
  }

}
