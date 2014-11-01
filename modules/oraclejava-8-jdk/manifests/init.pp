class oraclejava-8-jdk {
  include software-properties-common
  exec { 'setup_java_repo':
    command => "/usr/bin/add-apt-repository ppa:webupd8team/java -y && apt-get update -y",
    require => Package['software-properties-common'],
    creates => "/etc/apt/sources.list.d/webupd8team-java-trusty.list";
  }
  package {
    'debconf-utils':
  }
  exec { 'oracle_license_selected':
    command => '/bin/echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections',
    require => Package['debconf-utils'],
    unless => '/usr/bin/debconf-get-selections 2>/dev/null | grep shared/accepted-oracle-license-v1-1 | grep true';
  }
  # exec { 'oracle_license_seen':
  #   command => '/bin/echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections',
  #   require => [Package['debconf-utils'],Exec['oracle_license_selected']],
  #   unless => '/usr/bin/debconf-get-selections 2>/dev/null | grep shared/accepted-oracle-license-v1-1 | grep true';
  # }
  package {
    "oracle-java8-installer":
      ensure => installed,
      require => [Exec['oracle_license_seen'],Exec['oracle_license_selected']];
  }
  exec { 'use-java-8':
    command => "/usr/sbin/tupdate-java-alternatives -s java-8-oracle",
    unless => '/bin/ls -l /etc/alternatives/java | /bin/grep java-8-oracle',
    require => Package['oracle-java8-installer'];
  }
}
