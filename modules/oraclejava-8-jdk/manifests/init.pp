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
    command => 'echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections',
    require => Package['debconf-utils'],
    unless => 'debconf-get-selections 2>/dev/null | grep shared/accepted-oracle-license-v1-1';
  }
  exec { 'oracle_license_seen':
    command => 'echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections',
    require => Package['debconf-utils'],
    unless => 'debconf-get-selections 2>/dev/null | grep shared/accepted-oracle-license-v1-1';
  }
  package {
    "oracle-java8-installer":
      ensure => installed;
  }
  
  exec { 'use-java-8':
    command => "update-java-alternatives -s java-8-oracle",
    unless => 'ls -l /etc/alternatives/java | grep java-8-oracle',
    require => Package['oracle-java8-installer'];
  }
}
