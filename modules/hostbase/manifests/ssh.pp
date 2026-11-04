# @summary sshd drop-in and per-user authorized_keys outside the home directories
#
# @param authorized_keys Public keys per user, written to /etc/userkeys/<user>/authorized_keys.
class hostbase::ssh (
  Hash[String[1], Array[String[1]]] $authorized_keys = {},
) {
  file { '/etc/userkeys':
    ensure => directory,
  }

  $authorized_keys.each |$user, $keys| {
    file { "/etc/userkeys/${user}":
      ensure  => directory,
      require => File['/etc/userkeys'],
    }
    file { "/etc/userkeys/${user}/authorized_keys":
      ensure  => present,
      mode    => '0644',
      content => "${keys.join("\n")}\n",
      require => File["/etc/userkeys/${user}"],
    }
  }

  file { '/etc/ssh/sshd_config.d/99-homelab.conf':
    ensure  => present,
    mode    => '0644',
    content => file('hostbase/sshd-homelab.conf'),
    require => Package['openssh'],
    notify  => Service['sshd'],
  }

  service { 'sshd':
    ensure  => running,
    enable  => true,
    require => Package['openssh'],
  }
}
