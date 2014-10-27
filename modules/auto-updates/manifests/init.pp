class auto-updates {
  case $operatingsystem {
    'Solaris':          { include auto-updates::solaris }
    'RedHat', 'CentOS': { include auto-updates::red-hat  }
    /^(Debian|Ubuntu)$/:{ include auto-updates::debian  }
    default:            { include auto-updates::generic }
  }
}

class auto-updates::red-hat {
  package {
    "yum-cron":
      ensure => installed;
  }
  service {
    "yum-cron":
      ensure => running,
      enable => true;
  }
}

        
class auto-updates::debian {  
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
