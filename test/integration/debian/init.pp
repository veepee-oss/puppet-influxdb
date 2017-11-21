# -*- puppet -*-

exec { 'apt-get update':
  command => 'apt-get update -qq',
  path    => [ '/usr/bin', '/usr/sbin', '/bin', '/sbin' ],
}

class { 'influxdb':
  apt_location => 'http://mirror.vpgrp.io/debian-influxdb',
  package      => true,
  service      => true,
  require      => Exec['apt-get update'],
}
# EOF
