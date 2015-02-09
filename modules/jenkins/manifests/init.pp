class jenkins::conf {
  # rest is courtesy of https://github.com/jenkinsci/puppet-jenkins/blob/master/manifests/cli.pp
  $jenkins_cli_jar = "/var/lib/jenkins/jenkins-cli.jar"
  $extract_jar = "jar -xf /usr/share/jenkins/jenkins.war WEB-INF/jenkins-cli.jar"
  $move_jar = "mv WEB-INF/jenkins-cli.jar ${jenkins_cli_jar}"
  $remove_dir = 'rm -rf WEB-INF'

  exec { 'Extract jenkins-cli jar' :
    command => "service jenkins start && ${extract_jar} && ${move_jar} && ${remove_dir}",
    path    => ['/bin', '/usr/bin'],
    cwd     => '/tmp',
    creates => $jenkins_cli_jar,
    require => Package['jenkins'],
  }

  file { $jenkins_cli_jar:
    ensure  => file,
    require => Exec['Extract jenkins-cli jar'],
  }

}

define jenkins::jenkins_job($module, $relative_path = '', $use_auth = false, $username = '', $password = '') {
  include jenkins::conf
  $credentials_string = $use_auth ? {
    false => '',
    true => "--username $username --password '$password'"
  }

  file { "/tmp/${name}.job":
    mode => 644,
    owner => "jenkins",
    group => "nogroup",
    notify => Exec["${name}"],
    source => "puppet:///modules/${module}/${name}.job"
  }

  exec { "${name}":
    command => "/usr/bin/java -jar $jenkins::conf::jenkins_cli_jar -s http://localhost:8080/${relative_path} delete-job \"${name}\" ${credentials_string}; /usr/bin/java -jar $jenkins::conf::jenkins_cli_jar -s http://localhost:8080/${relative_path} create-job \"${name}\" ${credentials_string} < \"/tmp/${name}.job\"",
    user => 'jenkins',
    require => [File["/tmp/${name}.job"],File[$jenkins::conf::jenkins_cli_jar]],
    refreshonly => true,
    unless => "/usr/bin/java -jar $jenkins::conf::jenkins_cli_jar -s http://localhost:8080/${relative_path} get-job \"${name}\"",
    tries => 2,
    try_sleep => 20,
  }
}

define jenkins_plugin($version, $relative_path = '', $use_auth = false, $username = '', $password = '') {
  include jenkins::conf
  $credentials_string = $use_auth ? {
    true => "--username $username --password '$password'",
    false => ''
  }
  $written_git_jpi = $operatingsystemrelease ? {
    older => "/var/lib/jenkins/plugins/download/plugins/${name}/${version}/${name}.hpi",
    default => "/var/lib/jenkins/plugins/${name}.jpi"
  }
  exec { "wait for jenkins - $name":
    command => "/usr/bin/wget --spider --tries 10 --retry-connrefused http://localhost:8080/${relative_path}cli",
    returns => [0, 8],
    require => [Package["jenkins"],File[$jenkins::conf::jenkins_cli_jar]]
  }
  exec { "install jenkins plugin - $name":
      command => "/usr/bin/java -jar $jenkins::conf::jenkins_cli_jar -s http://localhost:8080/${relative_path} install-plugin ${credentials_string} http://updates.jenkins-ci.org/download/plugins/${name}/${version}/${name}.hpi -restart",
      user => 'jenkins',
      require => [Exec["wait for jenkins - $name"],File[$jenkins::conf::jenkins_cli_jar]],
      tries => 8,
      try_sleep => 15,
      unless => "/bin/ls $written_git_jpi";
  }
}

define jenkins($site = $name, $certfile = $name, $relative_path = '', $use_auth = false, $username = '', $password = '', $stable = true) { # 'ssl-cert-snakeoil' is another popular choice
  include apache2
  include wget
  if $stable == true {
    $apt_flag_file = "/var/lib/apt/lists/pkg.jenkins-ci.org_debian-stable_binary_Packages"
    $apt_key_url = "http://pkg.jenkins-ci.org/debian-stable/jenkins-ci.org.key"
    $jenkins_list_source = "puppet:///modules/jenkins/jenkins-stable.list"
  } else {
    $apt_flag_file = "/var/lib/apt/lists/pkg.jenkins-ci.org_debian_binary_Packages"
    $apt_key_url = "http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key"
    $jenkins_list_source = "puppet:///modules/jenkins/jenkins.list"
  }
  exec { 'install_jenkins_key':
    command => "/usr/bin/wget -q -O - $apt_key_url | sudo /usr/bin/apt-key add -",
    require => Package['wget'],
    unless => "/usr/bin/apt-key list | grep kk@kohsuke.org"
  }
  exec { 'Extra jenkins apt-get update':
    command => '/usr/bin/apt-get update',
    require => File['/etc/apt/sources.list.d/jenkins.list'],
    creates => "$apt_flag_file";
  }
  file { "/etc/apt/sources.list.d/jenkins.list":
    owner => root,
    group => root,
    mode => 0644,
    source => $jenkins_list_source,
    require => Exec[install_jenkins_key],
  }
  package { "jenkins":
    ensure => installed,
    require => Exec['Extra jenkins apt-get update'],
  }
  service {
    "jenkins":
      ensure => running,
      notify => Service["apache2"]
  }
  user { "jenkins":
    groups => ["rvm"],
    require => Package["jenkins"]
  }
  file { "/etc/default/jenkins":
    mode => 644,
    owner => root,
    group => root,
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
    use_auth => $use_auth,
    username => $username,
    password => $password,
    version => '1.2.0',
    relative_path => $relative_path
  }
  jenkins_plugin { 'git-client':
    use_auth => $use_auth,
    username => $username,
    password => $password,
    version => '1.0.2',
    relative_path => $relative_path
  }
  apache2::loadmodule { 'rewrite': }
  apache2::loadsite{"jenkins":}
}
