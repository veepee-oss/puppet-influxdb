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
    if $retention_duration != undef {

      # Try to retain idempotency in common cases like integer number of days or weeks
      # by normalising to "XXh0m0s" as returned by InfluxDB's SHOW RETENTION POLICIES.
      if $retention_duration =~ /(\d+)w/ {
        $duration_weeks = Integer($1)
      } else {
        $duration_weeks = 0
      }
      if $retention_duration =~ /(\d+)d/ {
        $duration_days = Integer($1)
      } else {
        $duration_days = 0
      }
      if $retention_duration =~ /(\d+)h/ {
        $duration_hours = Integer($1)
      } else {
        $duration_hours = 0
      }
      if $retention_duration =~ /(\d+)m/ {
        $duration_minutes = Integer($1)
      } else {
        $duration_minutes = 0
      }
      if $retention_duration =~ /(\d+)s/ {
        $duration_seconds = Integer($1)
      } else {
        $duration_seconds = 0
      }

      $duration_total_seconds = ((((((( $duration_weeks * 7 ) +
                                        $duration_days ) * 24 ) +
                                        $duration_hours ) * 60 ) +
                                        $duration_minutes ) * 60 ) +
                                        $duration_seconds

      $normalised_hours = $duration_total_seconds / 3600
      $normalised_minutes = ($duration_total_seconds / 60) - ($normalised_hours * 60)
      $normalised_seconds = $duration_total_seconds - ($normalised_hours * 3600 + $normalised_minutes * 60)

      $normalised_format = if $normalised_hours > 0 {
        '%dh%dm%ds'
      } elsif $normalised_minutes > 0 {
        '%dm%ds'
      } else {
        '%ds'
      }

      $normalised_retention_duration = sprintf($normalised_format, $normalised_hours, $normalised_minutes, $normalised_seconds)
      $with_duration_clause = "WITH DURATION ${normalised_retention_duration}"
    } else {
      $with_duration_clause = ''
    }

    exec { "create_database_${db_name}":
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command => "${cmd} \
        -execute 'CREATE DATABASE ${db_name} ${with_duration_clause}'",
      unless  => "${cmd} \
        -execute 'SHOW DATABASES' | tail -n+3 | grep -x ${db_name}",
      require => Class['influxdb']
    }

    if $retention_duration != undef {
      # Assume retention_duration applies to the default policy, regardless of its name.
      exec { "set_default_retention_policy_on_${db_name}":
        path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
        command => "${cmd} \
          -execute 'ALTER RETENTION POLICY \
          \"'\$(${cmd} -execute 'show retention policies on ${db_name}' | tail -n+3 | awk '\$5==\"true\" {print \$1}')'\" \
          ON \"${db_name}\" DURATION ${normalised_retention_duration}'",
        unless  => "${cmd} \
          -execute 'SHOW RETENTION POLICIES ON ${db_name}' | tail -n+3 \
          | awk '\$5==\"true\" && \$2 ~ /^${normalised_retention_duration}\$/ {OK = 1}; END {exit !OK}'",
        require => Exec["create_database_${db_name}"]
      }
    }
  }
}
# EOF
