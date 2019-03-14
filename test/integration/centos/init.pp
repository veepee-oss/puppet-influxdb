# -*- puppet -*-

class { 'influxdb':
  package => true,
  service => true,
}

influxdb::database { 'test':
    ensure  => present
  }
# EOF
