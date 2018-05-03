# == Class: influxdb::database
#
define influxdb::database (
  Enum['absent', 'present'] $ensure  = present,
  $db_name                           = $title,
  $cmd                               = 'influx -execute'
) {
  if ($ensure == 'absent') {
    exec { "drop_database_${db_name}":
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command => "${cmd} 'DROP DATABASE ${db_name}'",
      onlyif  => "${cmd} 'SHOW DATABASES' | grep ${db_name}"
    }
  } elsif ($ensure == 'present') {
    exec { "create_database_${db_name}":
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command => "${cmd} 'CREATE DATABASE ${db_name}'",
      unless  => "${cmd} 'SHOW DATABASES' | grep ${db_name}"
    }
  }
}
# EOF
