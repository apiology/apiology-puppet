class auto_updates {
  case $operatingsystem {
    'Solaris':          { include auto_updates::solaris }
    'RedHat', 'CentOS': { include auto_updates::red_hat  }
    /^(Debian|Ubuntu)$/:{ include auto_updates::debian  }
    default:            { include auto_updates::generic }
  }
}

class auto_updates::red_hat {
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

        
class auto_updates::debian {  
  package {
    "unattended-upgrades":
      ensure => installed;
  }
  file { "/etc/apt/apt.conf.d/20auto-upgrades":
    mode => "644",
    owner => "root",
    group => "root",
    require => Package["unattended-upgrades"],
    source => "puppet:///modules/auto_updates/20auto-upgrades"
  }
  file_line { 'Allow reboot after update':
    path  => '/etc/apt/apt.conf.d/50unattended-upgrades',
    line  => 'Unattended-Upgrade::Automatic-Reboot "true";',
    require => Package["unattended-upgrades"],
    match => '.*Unattended-Upgrade::Automatic-Reboot .*;',
  }
}
