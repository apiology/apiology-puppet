class xvfb {
  package {
    "xvfb":
      ensure => installed;
  }
  file {
    "/etc/init.d/xvfb":
      owner => root,
      group => root,
      mode => 0755,
      source => 'puppet:///modules/xvfb/xvfb'
  }
  service {
    "xvfb":
      ensure => running,
      enable => true,
      require => [File["/etc/init.d/xvfb"],Package["xvfb"]]
  }
}
