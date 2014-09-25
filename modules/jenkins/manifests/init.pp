class jenkins {
  exec { 'install_jenkins_key':
    command => "wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -",
    require => Package['wget'],
    unless => "apt-key list | grep kk@kohsuke.org"
  }
  exec { 'Extra jenkins apt-get update':
    command => '/usr/bin/apt-get update',
    require => File['/etc/apt/sources.list.d/jenkins.list'],
    creates => "/var/lib/apt/lists/pkg.jenkins-ci.org_debian-stable_binary_Packages"
  }
  file { "/etc/apt/sources.list.d/jenkins.list":
    owner => root,
    group => root,
    mode => 0644,
    source => "puppet:///modules/jenkins/jenkins.list",
    require => Exec[install_jenkins_key],
  }
  package { "jenkins":
    ensure => installed,
    require => Exec['Extra jenkins apt-get update'],
  }
  service {
    "jenkins":
      ensure => running;
  }
  user { "jenkins":
    groups => ["rvm"],
    require => Package["jenkins"]
  }
  file { "/etc/default/jenkins":
    mode => 644,
    owner => "root",
    group => "root",
    require => Package["jenkins"],
    source => "puppet:///modules/jenkins/etc-default-jenkins",
    notify => Service["jenkins"],
  }
  $cli_jar = $operatingsystemrelease ? {
    14.04 => "/var/cache/jenkins/war/WEB-INF/jenkins-cli.jar",
    default => "/var/cache/jenkins/war/WEB-INF/jenkins-cli.jar",
    something_else => "/usr/share/jenkins/cli/java/cli.jar"
  }
  $written_git_jpi = $operatingsystemrelease ? {
    12.04 => "/var/lib/jenkins/plugins/download/plugins/git/1.2.0/git.hpi",
    default => "/var/lib/jenkins/plugins/git.jpi"
  }
  exec {
    "java -jar $cli_jar -s http://localhost:8080/jenkins install-plugin http://updates.jenkins-ci.org/download/plugins/git-client/1.0.2/git-client.hpi && java -jar $cli_jar -s http://localhost:8080/jenkins install-plugin http://updates.jenkins-ci.org/download/plugins/git/1.2.0/git.hpi -restart":
    user => 'jenkins',
    require => Service["jenkins"],
    tries => 5,
    try_sleep => 7,
    unless => "ls $written_git_jpi"
  }
  file { "/etc/apache2/conf-available/jenkins.conf":
    owner => root,
    group => root,
    mode => 0644,
    source => "puppet:///modules/jenkins/jenkins.conf",
    notify => Service[apache2],
    require => Package[apache2];
  }
  apache2::loadconf{"jenkins":}
}
