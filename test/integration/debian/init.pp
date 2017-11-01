# -*- puppet -*-

exec { 'apt-get update':
  command => 'apt-get update -qq',
  path    => [ '/usr/bin', '/usr/sbin', '/bin', '/sbin' ],
}

class { 'influxdb':
  package => true,
  service => true,
  require => Exec['apt-get update'],
}
# EOF
