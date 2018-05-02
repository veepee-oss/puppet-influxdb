# == Class: influxdb::user
#
define influxdb::user (
  Enum['absent', 'present'] $ensure       = present,
  $db_user                                = $title,
  $db_name                                = undef,
  Enum['ALL', 'READ', 'WRITE'] $privilege = 'ALL',
  $passwd                                 = undef
) {
  $cmd = 'influx -execute'

  if ($ensure == 'absent') {
    exec { 'revoke_user':
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command =>
        "${cmd} 'REVOKE ${privilege} ON \"${db_name}\" TO \"${db_user}\"'",
      onlyif  =>
        "${cmd} 'SHOW GRANTS FOR \"db_user\"' | grep ${privilege}"
    }
    ->  exec { 'drop_user':
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command => "${cmd} 'DROP USER \"${db_user}\"'",
      onlyif  => "${cmd} 'SHOW USERS' | grep ${db_user}"
    }
  } elsif ($ensure == 'present') {
    exec { 'create_user':
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command =>
        "${cmd} \"CREATE USER \\\"${db_user}\\\" WITH PASSWORD '${passwd}'\"",
      unless  => "${cmd} 'SHOW USERS' | grep ${db_user}"
    }
    -> exec { 'grant_user':
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command =>
        "${cmd} 'GRANT ${privilege} ON \"${db_name}\" TO \"${db_user}\"'",
      unless  =>
        "${cmd} 'SHOW GRANTS FOR \"db_user\"' | grep ${privilege}"
    }
  }
}
# EOF
