# == Class: influxdb::user
#
define influxdb::user (
  Enum['absent', 'present'] $ensure = present,
  $db_user                          = $title,
  $passwd                           = undef,
  $is_admin                         = false,
  $https_enable                     = $influxdb::https_enable,
  $http_auth_enabled                = $influxdb::http_auth_enabled,
  $admin_username                   = $influxdb::admin_username,
  $admin_password                   = $influxdb::admin_password
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

  if ($ensure == 'absent') {
    exec { "drop_user_${db_user}":
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command => "${cmd} \
        -execute 'DROP USER \"${db_user}\"'",
      onlyif  => "${cmd} \
        -execute 'SHOW USERS' | tail -n+3 | awk '{print \$1}' |\
        grep -x ${db_user}"
    }
  } elsif ($ensure == 'present') {
    $arg_p = "WITH PASSWORD '${passwd}'"
    if $is_admin {
      $arg_a = 'WITH ALL PRIVILEGES'
    } else {
      $arg_a = ''
    }
    exec { "create_user_${db_user}":
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command => "${cmd} \
        -execute \"CREATE USER \\\"${db_user}\\\" ${arg_p} ${arg_a}\"",
      unless  => "${cmd} \
        -execute 'SHOW USERS' | tail -n+3 | awk '{print \$1}' |\
        grep -x ${db_user}"
    }
  }
}
# EOF
