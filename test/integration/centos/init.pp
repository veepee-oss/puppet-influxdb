# -*- puppet -*-

class { 'influxdb':
  package => true,
  service => true,
}
# EOF
