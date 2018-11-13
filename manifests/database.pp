# == Class: influxdb::database
#
define influxdb::database (
  Enum['absent', 'present'] $ensure  = present,
  $db_name                           = $title,
  $http_auth_enabled                 = $influxdb::http_auth_enabled,
  $admin_username                    = $influxdb::admin_username,
  $admin_password                    = $influxdb::admin_password
) {
  if ($ensure == 'absent') and ($http_auth_enabled == true) {
    exec { "drop_database_${db_name}":
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command =>
        "influx -username ${admin_username} -password '${admin_password}' \
        -execute 'DROP DATABASE ${db_name}'",
      onlyif  =>
        "influx -username ${admin_username} -password '${admin_password}' \
        -execute 'SHOW DATABASES' | tail -n+3 | grep ${db_name}"
    }
  } elsif ($ensure == 'present') and ($http_auth_enabled == true) {
    exec { "create_database_${db_name}":
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command =>
        "influx -username ${admin_username} -password '${admin_password}' \
        -execute 'CREATE DATABASE ${db_name}'",
      unless  =>
        "influx -username ${admin_username} -password '${admin_password}' \
        -execute 'SHOW DATABASES' | tail -n+3 | grep ${db_name}"
    }
  } elsif ($ensure == 'present') and ($http_auth_enabled == false) {
    exec { "create_database_${db_name}":
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command => "influx -execute 'CREATE DATABASE ${db_name}'",
      unless  =>
        "influx -execute 'SHOW DATABASES' | tail -n+3 | grep ${db_name}"
    }
  } elsif ($ensure == 'absent') and ($http_auth_enabled == false) {
    exec { "drop_database_${db_name}":
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command => "influx -execute 'DROP DATABASE ${db_name}'",
      onlyif  =>
        "influx -execute 'SHOW DATABASES' | tail -n+3 | grep ${db_name}"
    }
  }
}
# EOF
