class { 'apt': }

class emacs24 {
  exec { 'setup_emacs_repo':
     command => "/usr/bin/add-apt-repository ppa:cassou/emacs -y && apt-get update -y",
     require => Package['software-properties-common'],
     creates => "/etc/apt/sources.list.d/cassou-emacs-trusty.list";
  }
  package {
    "emacs24":
      ensure => installed,
      require => Exec['setup_emacs_repo'];
  }
}
