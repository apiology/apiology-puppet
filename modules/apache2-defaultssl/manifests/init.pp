class apache2-defaultssl {
  include apache2
  file { "/etc/apache2/sites-available/default-ssl.conf": }
  apache2::loadsite{"default-ssl":}
}
