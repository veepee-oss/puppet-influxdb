# == Class: influxdb::user
#
define influxdb::user (
  Enum['absent', 'present'] $ensure = present,
  $db_user                          = $title,
  $passwd                           = undef,
  $is_admin                         = false,
  $http_auth_enabled                = $influxdb::http_auth_enabled,
  $admin_username                   = $influxdb::admin_username,
  $admin_password                   = $influxdb::admin_password
) {
  if ($ensure == 'absent') and ($http_auth_enabled == true) {
    exec { "drop_user_${db_user}":
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command =>
        "influx -username ${admin_username} -password '${admin_password}' \
        -execute 'DROP USER \"${db_user}\"'",
      onlyif  =>
        "influx -username ${admin_username} -password '${admin_password}' \
        -execute 'SHOW USERS' | tail -n+3 | awk '{print \$1}' |\
        grep -x ${db_user}"
    }
  } elsif ($ensure == 'present') and ($http_auth_enabled == true) {
    $arg_p = "WITH PASSWORD '${passwd}'"
    if $is_admin {
      $arg_a = 'WITH ALL PRIVILEGES'
    } else {
      $arg_a = ''
    }
    exec { "create_user_${db_user}":
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command =>
        "influx -username ${admin_username} -password '${admin_password}' \
        -execute \"CREATE USER \\\"${db_user}\\\" ${arg_p} ${arg_a}\"",
      unless  =>
        "influx -username ${admin_username} -password '${admin_password}' \
        -execute 'SHOW USERS' | tail -n+3 | awk '{print \$1}' |\
        grep -x ${db_user}"
    }
  } elsif ($ensure == 'absent') and ($http_auth_enabled == false) {
    exec { "drop_user_${db_user}":
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command => "influx -execute 'DROP USER \"${db_user}\"'",
      onlyif  => "influx -execute 'SHOW USERS' | tail -n+3 |\
      awk '{print \$1}' | grep -x ${db_user}"
    }
  } elsif ($ensure == 'present') and ($http_auth_enabled == false) {
    $arg_p = "WITH PASSWORD '${passwd}'"
    if $is_admin {
      $arg_a = 'WITH ALL PRIVILEGES'
    } else {
      $arg_a = ''
    }
    exec { "create_user_${db_user}":
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command =>
        "influx -execute \"CREATE USER \\\"${db_user}\\\" ${arg_p} ${arg_a}\"",
      unless  =>
        "influx -execute 'SHOW USERS' | tail -n+3 | awk '{print \$1}' |\
        grep -x ${db_user}"
    }
  }
}
# EOF
