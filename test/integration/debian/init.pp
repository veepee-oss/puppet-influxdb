# -*- puppet -*-

exec { 'apt-get update':
  command => 'apt-get update -qq',
  path    => [ '/usr/bin', '/usr/sbin', '/bin', '/sbin' ],
}

if ($::lsbdistid == 'Debian') {
  class { 'influxdb':
    apt_location => 'http://mirror.vpgrp.io/debian-influxdb',
    package      => true,
    service      => true,
    require      => Exec['apt-get update'],
  }
}

if ($::lsbdistid == 'Ubuntu') {
  class { 'influxdb':
    apt_location => 'http://mirror.vpgrp.io/ubuntu-influxdb',
    package      => true,
    service      => true,
    require      => Exec['apt-get update'],
  }
}
# EOF
