# == Class: influxdb::database
#
define influxdb::database (
  Enum['absent', 'present'] $ensure  = present,
  $db_name                           = $title
) {
  if ($ensure == 'absent') {
    exec { 'drop_database':
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command => "influx -execute 'DROP DATABASE ${db_name}'",
      onlyif  => "influx -execute 'SHOW DATABASES' | grep ${db_name}"
    }
  } elsif ($ensure == 'present') {
    exec { 'create_database':
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command => "influx -execute 'CREATE DATABASE ${db_name}'",
      unless  => "influx -execute 'SHOW DATABASES' | grep ${db_name}"
    }
  }
}
# EOF
