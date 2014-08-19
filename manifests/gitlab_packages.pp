# class: getvalkyrie::gitlab::packages
#
# Install and configure gitlab pre-requisites.
#
# N.B. To shorten the development cycle, we build a (local) base image with all
# required packages pre-installed.
class getvalkyrie::gitlab_packages {

  exec { 'initial update':
    command   => '/usr/bin/apt-get update',
  }

  Exec['initial update'] -> Package <| |>

  package {[
    'bundler',
    'curl',
    'git',
    'libicu-dev',
    'libmysql++-dev',
    'libmysqlclient-dev',
    'libpq-dev',
    'libxslt1-dev',
    'logrotate',
    'postfix',
    'python2.7',
    'python-dev',
    'python-docutils',
    'redis-server',
  ]:
    ensure => present,
  }

  package {[ 'g++-4.8', 'ruby1.9.1-dev', 'build-essential' ]:
    before => File['/usr/bin/g++'],
  }->
  file {'/usr/bin/g++':
    ensure  => link,
    target  => '/usr/bin/g++-4.8',
  }->
  package { 'charlock_holmes':
    ensure    => '0.6.9.4',
    provider  => gem,
  }

}
