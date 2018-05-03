# == Class: influxdb::privilege
#
define influxdb::privilege (
  Enum['absent', 'present'] $ensure       = present,
  $db_user                                = undef,
  $db_name                                = undef,
  Enum['ALL', 'READ', 'WRITE'] $privilege = 'ALL',
  $cmd                                    = $influxdb::params::execute
) inherits influxdb::params {
  $matches = "grep ${db_name} | grep ${privilege}"
  if ($ensure == 'absent') {
    exec { 'revoke_user':
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command =>
        "${cmd} 'REVOKE ${privilege} ON \"${db_name}\" TO \"${db_user}\"'",
      onlyif  => "${cmd} 'SHOW GRANTS FOR \"${db_user}\"' | ${matches}"
    }
  } elsif ($ensure == 'present') {
    exec { 'grant_user':
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command =>
        "${cmd} 'GRANT ${privilege} ON \"${db_name}\" TO \"${db_user}\"'",
      unless  => "${cmd} 'SHOW GRANTS FOR \"${db_user}\"' | ${matches}"
    }
  }
}
# EOF
