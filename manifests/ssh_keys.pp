# class: getvalkyrie::ssh_keys
#
# Generate an SSH keypair. $image_name and $image_tag are set as facts.
class getvalkyrie::ssh_keys {
  getvalkyrie::ssh_key { $::image_name : key_tag => $::image_tag }
}

# defined type: getvalkyrie::ssh_key
#
# Generates an SSH keypair, saved to a mounted volume, that can then be used to
# securely connect to the container.
define getvalkyrie::ssh_key (
  $key_tag,
  $user = 'root',
  $home = '/root',
  $key_path = false,
) {

  if !defined(Package['openssh-server']) {
    package {'openssh-server':
      ensure => present,
      before => Exec['ssh-keygen'],
    }
  }

  # Set a default path to store keys, but allow overrides.
  if $key_path {$real_keypath = $key_path}
  else { $real_keypath = "/tmp/ssh_keys/${name}_${key_tag}"}

  # Generate a strong keypair and save it to a mounted volume.
  exec {'ssh-keygen':
    command => "/usr/bin/ssh-keygen -t rsa -b 4096 -N '' -C '${name}_${key_tag}' -f ${real_keypath}",
    user    => $user,
    creates => [ "${real_keypath}", "${real_keypath}.pub" ],
  }

  # Secure the user's SSH directory.
  file {"${home}/.ssh":
    ensure => directory,
    owner  => $user,
    mode   => 700,
    before => Exec['ssh-keygen'],
  }

  # Grant SSH access as the specified user to the keypair.
  file {"${home}/.ssh/authorized_keys":
    ensure  => file,
    source  => "${real_keypath}.pub",
    owner   => $user,
    mode    => 600,
    require => [
      Exec['ssh-keygen'],
      File["${home}/.ssh"],
    ]
  }

}
