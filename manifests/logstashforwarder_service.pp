# class: getvalkyrie::logstashforwarder_service
#
# Install logstash forwarder.
class getvalkyrie::logstashforwarder_service (
  $version = '0.3.1',
) {

  class { 'logstashforwarder':
    version => $version,
    status  => 'disabled',
    manage_repo => true,
    servers => ['localhost'],
  }

  supervisor::service { 'logstashforwarder':
    ensure  => present,
    command => '/opt/logstash-forwarder/bin/logstash-forwarder',
    require => Class['logstashforwarder'];
  }

}
