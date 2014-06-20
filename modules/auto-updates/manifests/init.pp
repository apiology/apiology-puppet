class auto-updates {
  package {
    "unattended-upgrades":
      ensure => installed;
  }
  file { "/etc/apt/apt.conf.d/20auto-upgrades":
    mode => 644,
    owner => "root",
    group => "root",
    require => Package["unattended-upgrades"],
    source => "puppet:///modules/auto-updates/20auto-upgrades"
  }
  file_line { 'Allow reboot after update':
    path  => '/etc/apt/apt.conf.d/50unattended-upgrades',
    line  => 'Unattended-Upgrade::Automatic-Reboot "true";',
    require => Package["unattended-upgrades"],
    match => '.*Unattended-Upgrade::Automatic-Reboot .*;',
  }
}
