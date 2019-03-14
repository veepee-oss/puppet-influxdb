# -*- puppet -*-
if ($::lsbdistid == 'Debian') {
  class { 'influxdb':
    apt_location => 'http://mirror.vpgrp.io/debian-influxdb',
    package      => true,
    service      => true
  }

  influxdb::database { 'test':
    ensure  => present
  }
}

if ($::lsbdistid == 'Ubuntu') {
  class { 'influxdb':
    apt_location => 'http://mirror.vpgrp.io/ubuntu-influxdb',
    package      => true,
    service      => true
  }

  influxdb::database { 'test':
    ensure  => present
  }
}
# EOF
