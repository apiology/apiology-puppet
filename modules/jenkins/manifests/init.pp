$jenkins_cli_jar = $operatingsystemrelease ? {
  14.04 => "/var/cache/jenkins/war/WEB-INF/jenkins-cli.jar",
  default => "/var/cache/jenkins/war/WEB-INF/jenkins-cli.jar",
  something_else => "/usr/share/jenkins/cli/java/cli.jar"
}

define jenkins_job($module, $relative_path = '') {
  file { "/tmp/${name}.job":
    mode => 644,
    owner => "jenkins",
    group => "nogroup",
    require => Service['jenkins'],
    notify => Exec["${name}"],
    source => "puppet:///modules/${module}/${name}.job"
  }
  exec { "${name}":
    command => "/usr/bin/java -jar $jenkins_cli_jar -s http://localhost:8080/${relative_path} delete-job \"${name}\"; /usr/bin/java -jar $jenkins_cli_jar -s http://localhost:8080/${relative_path} create-job \"${name}\" < \"/tmp/${name}.job\"",
    user => 'jenkins',
    require => [File["/tmp/${name}.job"],Service['jenkins']],
    unless => "/usr/bin/java -jar $jenkins_cli_jar -s http://localhost:8080/${relative_path} get-job \"${name}\"",
    tries => 5,
    try_sleep => 30,
  }
}

# git 1.2.0
# git-client = 1.0.2
define jenkins_plugin($version, $relative_path = '') {
  $jenkins_cli_jar = $operatingsystemrelease ? {
    14.04 => "/var/cache/jenkins/war/WEB-INF/jenkins-cli.jar",
    default => "/var/cache/jenkins/war/WEB-INF/jenkins-cli.jar",
    something_else => "/usr/share/jenkins/cli/java/cli.jar"
  }
  $written_git_jpi = $operatingsystemrelease ? {
    default => "/var/lib/jenkins/plugins/download/plugins/${name}/${version}/${name}.hpi",
    older => "/var/lib/jenkins/plugins/${name}.jpi"
  }
  exec {
    "/usr/bin/java -jar $jenkins_cli_jar -s http://localhost:8080/${relative_path} install-plugin http://updates.jenkins-ci.org/download/plugins/${name}/${version}/${name}.hpi -restart":
    user => 'jenkins',
    require => Service["jenkins"],
    tries => 5,
    try_sleep => 7,
    unless => "/bin/ls $written_git_jpi"
  }
}

define jenkins($site = $name, $certfile = $name, $relative_path = '') { # 'ssl-cert-snakeoil' is another popular choice
  include apache2
  include wget
  exec { 'install_jenkins_key':
    command => "/usr/bin/wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo /usr/bin/apt-key add -",
    require => Package['wget'],
    unless => "/usr/bin/apt-key list | grep kk@kohsuke.org"
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
    content => template('jenkins/etc-default-jenkins.erb'),
    notify => Service["jenkins"],
  }
  file { "/etc/apache2/sites-available/jenkins.conf":
    owner => root,
    group => root,
    mode => 0644,
    content => template('jenkins/jenkins.conf.erb'),
    notify => [Service['apache2'], apache2::loadsite['jenkins']],
    require => Package[apache2];
  }
  jenkins_plugin { 'git':
    version => '1.2.0',
    relative_path => $relative_path
  }
  jenkins_plugin { 'git-client':
    version => '1.0.2',
    relative_path => $relative_path
  }
  apache2::loadmodule { 'rewrite': }
  apache2::loadsite{"jenkins":}
}
