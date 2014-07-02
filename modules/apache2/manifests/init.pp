define apache2::loadmodule () {
  file { "/etc/apache2/mods-available/${name}.load": }
  exec { "/usr/sbin/a2enmod $name" :
    unless => "/bin/readlink -e /etc/apache2/mods-enabled/${name}.load",
    require => [Package[apache2],File["/etc/apache2/mods-available/${name}.load"]],
    notify => Service[apache2]
  }
}

define apache2::loadconf () {
  exec { "/usr/sbin/a2enconf $name" :
    unless => "/bin/readlink -e /etc/apache2/conf-enabled/${name}.conf",
    require => [Package[apache2],File["/etc/apache2/conf-available/${name}.conf"]],
    notify => Service[apache2]
  }
}

define apache2::loadsite () {
  file { "/etc/apache2/sites-available/${name}.conf": }
  exec { "/usr/sbin/a2ensite $name" :
    unless => "/bin/readlink -e /etc/apache2/sites-enabled/${name}.conf",
    require => [Package[apache2],File["/etc/apache2/sites-available/${name}.conf"]],
    notify => Service[apache2]
  }
}

define apache2::dissite () {
  exec { "/usr/sbin/a2dissite $name" :
    onlyif => "/bin/readlink -e /etc/apache2/sites-enabled/${name}",
    require => Package[apache2],
    notify => Service[apache2]
  }
}

class apache2 {

  package {
    "apache2":
      ensure => present
  }

  apache2::loadmodule{"ssl":}
  apache2::loadmodule{"cgid":}
  apache2::loadmodule{"alias":}
  apache2::loadmodule{"env":}
  apache2::loadmodule{"proxy":}
  apache2::loadmodule{"proxy_http":}
  apache2::loadmodule{"vhost_alias":}
  apache2::loadmodule{"headers":}
  apache2::loadsite{"default-ssl":}

  file { "/etc/apache2/authusers":
    owner => root,
    group => www-data,
    mode => 0640,
    ensure => file,
    require => Package[apache2]
  }
  
  exec { "/usr/sbin/make-ssl-cert generate-default-snakeoil --force-overwrite":
    notify => Service[apache2],
    unless => '[ /etc/ssl/certs/ssl-cert-snakeoil.pem -nt /etc/ssl/certs/ca-certificates.crt ]',
    provider => "shell",
    require => Package[apache2]
  }
  
  service {
    "apache2":
      ensure      => running,
      hasrestart  => true,
      hasstatus   => true,
      enable      => true,
      require     => Package["apache2"]
  }
}
