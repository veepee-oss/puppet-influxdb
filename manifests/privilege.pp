# == Class: influxdb::privilege
#
define influxdb::privilege (
  Enum['absent', 'present'] $ensure       = present,
  $db_user                                = undef,
  $db_name                                = undef,
  Enum['ALL', 'READ', 'WRITE'] $privilege = 'ALL',
  $https_enable                           = $influxdb::https_enable,
  $http_auth_enabled                      = $influxdb::http_auth_enabled,
  $admin_username                         = $influxdb::admin_username,
  $admin_password                         = $influxdb::admin_password
) {
  if $https_enable {
    $ssl_opts = '-ssl -unsafeSsl'
  } else {
    $ssl_opts = ''
  }

  if $http_auth_enabled {
    $auth_opts = "-username ${admin_username} -password '${admin_password}'"
  } else {
    $auth_opts = ''
  }

  $cmd = "influx ${ssl_opts} ${auth_opts}"

  $matches = "grep ${db_name} | grep ${privilege}"

  if ($ensure == 'absent') {
    exec { "revoke_${privilege}_on_${db_name}_to_${db_user}":
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command => "${cmd} \
         -execute 'REVOKE ${privilege} ON \"${db_name}\" TO \"${db_user}\"'",
      onlyif  => "${cmd} \
        -execute  'SHOW GRANTS FOR \"${db_user}\"' | ${matches}"
    }
  } elsif ($ensure == 'present') {
    exec { "grant_${privilege}_on_${db_name}_to_${db_user}":
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command => "${cmd} \
        -execute 'GRANT ${privilege} ON \"${db_name}\" TO \"${db_user}\"'",
      unless  => "${cmd} \
        -execute 'SHOW GRANTS FOR \"${db_user}\"' | ${matches}"
    }
  }
}
# EOF
