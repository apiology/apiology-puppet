class timezone {
  file {
    "/etc/localtime":
      ensure => "/usr/share/zoneinfo/US/Eastern"
  }

  file {
    "/etc/timezone":
      content => "US/Eastern\n",
  }

  file {
    "/etc/default/locale":
      content => "LANG=\"en_US.UTF-8\"\nLANGUAGE=\"en_US:en\"\n"
  }
}
