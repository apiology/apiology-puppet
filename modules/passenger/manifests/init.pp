class passenger {
  include apache2
  include apt-transport-https
  include ca-certificates

  exec { 'install_passenger_key':
    command => "/usr/bin/apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7",
    unless => "/usr/bin/apt-key list | grep auto-software-signing@phusion.nl"
  }
  file { "/etc/apt/sources.list.d/passenger.list":
    owner => root,
    group => root,
    mode => 0644,
    ensure => file;
  }
  if $::ubuntu_nickname == "" {
    fail("Define ubuntu_nickname variable")
  }
  file_line { "Add passenger.list entry":
    path => '/etc/apt/sources.list.d/passenger.list',
    line => "deb https://oss-binaries.phusionpassenger.com/apt/passenger $::ubuntu_nickname main",
    match => "^deb https://oss-binaries.phusionpassenger.com/apt/passenger .*",
    require => File['/etc/apt/sources.list.d/passenger.list'];
  }
  exec { 'Extra passenger apt-get update':
    command => '/usr/bin/apt-get update',
    require => [File_Line["Add passenger.list entry"],Exec['install_passenger_key']],
    creates => "/var/lib/apt/lists/oss-binaries.phusionpassenger.com_apt_passenger_dists_${::ubuntu_nickname}_Release";
  }
  package { "libapache2-mod-passenger":
    ensure => installed,
    require => [Exec['Extra passenger apt-get update'],Package['ca-certificates'],Package['apt-transport-https']],
    notify => Service[apache2];
  }
  apache2::loadmodule { "passenger": }

  Package["libapache2-mod-passenger"] -> Apache2::Loadmodule['passenger']
}

