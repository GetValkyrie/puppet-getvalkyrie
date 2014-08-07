# class: getvalkyrie::logstash_service
#
# Install elasticsearch at the specified version.
class getvalkyrie::logstash_service (
  $version = '1.4.2',
) {

  $logstash_deb_url = "https://download.elasticsearch.org/logstash/logstash/packages/debian/logstash_${version}-1-2c0f5a1_all.deb"
  $logstash_deb_path = "/tmp/cache/logstash-${version}-1-2c0f5a1_all.deb"
  wget::fetch { $logstash_deb_url:
    destination => $logstash_deb_path,
#    cache_dir   => '/tmp/cache',
    #verbose     => true,
  }

  # Install Logstash from the .deb packages we fetched.
  class { 'logstash':
    status            => 'unmanaged',
    restart_on_change => false,
    package_url       => "file:${logstash_deb_path}",
    java_install      => true,
    require           => Wget::Fetch[$logstash_deb_url],
  }

  #TODO: docker-elk/logstash.conf

  supervisor::service { 'logstash':
    ensure         => present,
    command        => '/opt/logstash/bin/logstash -f /etc/logstash/logstash.conf',
    stderr_logfile => '/var/log/supervisor/supervisor_err.log',
    stdout_logfile => '/var/log/supervisor/supervisor_out.log',
    require        => Class['logstash'],
  }

}
