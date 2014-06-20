class memcached {
  # necessary because there's a gem also named memcached, and puppet doesn't like
  # two packages with different providers.
  exec { "hack-memcached":
    command => "/usr/bin/apt-get install memcached",
    unless => "dpkg -s memcached >/dev/null 2>&1";
  }
  #package {
  #  "memcached":
  #    ensure => installed;
  #}
  service {
    "memcached":
      ensure      => running,
      enable      => true,
      require => Exec['hack-memcached']
  }
}
