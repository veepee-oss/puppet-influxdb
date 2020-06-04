# == Class: influxdb::database
#
define influxdb::database (
  Enum['absent', 'present'] $ensure  = present,
  $db_name                           = $title,
  $https_enable                      = $influxdb::https_enable,
  $http_auth_enabled                 = $influxdb::http_auth_enabled,
  $admin_username                    = $influxdb::admin_username,
  $admin_password                    = $influxdb::admin_password,
  $retention_duration                = $influxdb::default_retention_duration
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
    exec { "drop_database_${db_name}":
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command => "${cmd} \
        -execute 'DROP DATABASE ${db_name}'",
      onlyif  => "${cmd} \
        -execute 'SHOW DATABASES' | tail -n+3 | grep -x ${db_name}",
      require => Class['influxdb']
    }
  } elsif ($ensure == 'present') {

    # Try to retain idempotency in common cases like integer number of days or weeks
    # by normalising to "XXh0m0s" as returned by InfluxDB's SHOW RETENTION POLICIES.
    case $retention_duration {
      /^(\d+)w$/: {
        $normalised_retention_duration = sprintf("%dh0m0s", $1 * 24 * 7)
      }
      /^(\d+)d$/: {
        $normalised_retention_duration = sprintf("%dh0m0s", $1 * 24)
      }
      default: {
        $normalised_retention_duration = $retention_duration
      }
    }

    exec { "create_database_${db_name}":
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command => "${cmd} \
        -execute 'CREATE DATABASE ${db_name} WITH DURATION ${normalised_retention_duration}'",
      unless  => "${cmd} \
        -execute 'SHOW DATABASES' | tail -n+3 | grep -x ${db_name}",
      require => Class['influxdb']
    }

    # Assume retention_duration applies to the default policy, regardless of its name.
    exec { "set_default_retention_policy_on_${db_name}":
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command => "${cmd} \
        -execute 'ALTER RETENTION POLICY \
        \"'\$(${cmd} -execute 'show retention policies on ${db_name}' | tail -n+3 | awk '\$5==\"true\" {print \$1}')'\" \
        ON \"${db_name}\" DURATION ${normalised_retention_duration}'",
      unless  => "${cmd} \
        -execute 'SHOW RETENTION POLICIES ON ${db_name}' | tail -n+3 | awk '\$5==\"true\" && \$2 ~ /^${normalised_retention_duration}((0m)?0s)?\$/ {OK = 1}; END {exit !OK}'",
      require => Exec["create_database_${db_name}"]
    }
  }
}
# EOF
