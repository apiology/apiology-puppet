class ssh {
  package {
    "ssh":
      ensure => present,
      before => File["/etc/ssh/sshd_config"]
  }
  # vagrant can ssh to itself
#  exec { "vagrant_keygen":
#    command => 'ssh-keygen -q -t rsa -f /home/vagrant/.ssh/id_rsa -N ""',
#    require => Service["ssh"],
#    unless => "ls /home/vagrant/.ssh/id_rsa.pub",
#    user => vagrant
#  }
#  exec { "vagrant_selfaccess":
#    command => 'cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys',
#    user => "vagrant",
#    unless => "grep vagrant@ /home/vagrant/.ssh/authorized_keys",
#    require => Exec["vagrant_keygen"]
#  }
  file {
    "/etc/ssh/sshd_config":
      owner   => root,
      group   => root,
      mode    => 644,
      source  => "puppet:///modules/ssh/sshd_config"
  }
  service {
    "ssh":
      ensure    => true,
      enable    => true,
      subscribe => File["/etc/ssh/sshd_config"]
  }
}

