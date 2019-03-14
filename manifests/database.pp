# == Class: influxdb::database
#
define influxdb::database (
  Enum['absent', 'present'] $ensure  = present,
  $db_name                           = $title,
  $https_enable                      = $influxdb::https_enable,
  $http_auth_enabled                 = $influxdb::http_auth_enabled,
  $admin_username                    = $influxdb::admin_username,
  $admin_password                    = $influxdb::admin_password
) {
  if $https_enable {
    $cmd = 'influx -ssl -unsafeSsl'
  } else {
    $cmd = 'influx'
  }
  if ($ensure == 'absent') and ($http_auth_enabled == true) {
    exec { "drop_database_${db_name}":
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command =>
        "${cmd} -username ${admin_username} -password '${admin_password}' \
        -execute 'DROP DATABASE ${db_name}'",
      onlyif  =>
        "${cmd} -username ${admin_username} -password '${admin_password}' \
        -execute 'SHOW DATABASES' | tail -n+3 | grep -x ${db_name}",
      require => Class['influxdb']
    }
  } elsif ($ensure == 'present') and ($http_auth_enabled == true) {
    exec { "create_database_${db_name}":
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command =>
        "${cmd} -username ${admin_username} -password '${admin_password}' \
        -execute 'CREATE DATABASE ${db_name}'",
      unless  =>
        "${cmd} -username ${admin_username} -password '${admin_password}' \
        -execute 'SHOW DATABASES' | tail -n+3 | grep -x ${db_name}",
      require => Class['influxdb']
    }
  } elsif ($ensure == 'present') and ($http_auth_enabled == false) {
    exec { "create_database_${db_name}":
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command => "${cmd} -execute 'CREATE DATABASE ${db_name}'",
      unless  =>
        "${cmd} -execute 'SHOW DATABASES' | tail -n+3 | grep -x ${db_name}",
      require => Class['influxdb']
    }
  } elsif ($ensure == 'absent') and ($http_auth_enabled == false) {
    exec { "drop_database_${db_name}":
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command => "${cmd} -execute 'DROP DATABASE ${db_name}'",
      onlyif  =>
        "${cmd} -execute 'SHOW DATABASES' | tail -n+3 | grep -x ${db_name}",
      require => Class['influxdb']
    }
  }
}
# EOF
