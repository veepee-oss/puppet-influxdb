# == Class: influxdb
#
# Puppet module to install, deploy and configure influxdb.
#
class influxdb (
  $package                            = true,
  $service                            = true,
  $enable                             = true,
  $manage_repo                        = true,
  $split_client_package               = false,
  $apt_location                       = $influxdb::params::apt_location,
  $apt_release                        = $influxdb::params::apt_release,
  $apt_repos                          = $influxdb::params::apt_repos,
  $apt_key                            = $influxdb::params::apt_key,
  $influxdb_package_name              = $influxdb::params::influxdb_package_name,
  $influxdb_service_name              = $influxdb::params::influxdb_service_name,
  $influxdb_service_provider          = $influxdb::params::influxdb_service_provider,
  # daemon settings
  $hostname                           = $::fqdn,
  $libdir                             = $influxdb::params::libdir,
  $admin_enable                       = $influxdb::params::admin_enable,
  $admin_bind_address                 = $influxdb::params::admin_bind_address,
  $admin_username                     = $influxdb::params::admin_username,
  $admin_password                     = $influxdb::params::admin_password,
  $domain_name                        = $influxdb::params::domain_name,
  $flux_enable                        = $influxdb::params::flux_enable,
  $http_enable                        = $influxdb::params::http_enable,
  $http_bind_address                  = $influxdb::params::http_bind_address,
  $http_auth_enabled                  = $influxdb::params::http_auth_enabled,
  $http_realm                         = $influxdb::params::http_realm,
  $http_log_enabled                   = $influxdb::params::http_log_enabled,
  $https_enable                       = $influxdb::params::https_enable,
  $http_socket_enable                 = $influxdb::params::http_socket_enable,
  $http_bind_socket                   = $influxdb::params::http_bind_socket,
  $logging_format                     = $influxdb::params::logging_format,
  $logging_level                      = $influxdb::params::logging_level,
  $index_version                      = $influxdb::params::index_version,
  $cache_max_memory_size              = $influxdb::params::cache_max_memory_size,
  $cache_snapshot_memory_size         = $influxdb::params::cache_snapshot_memory_size,
  $cache_snapshot_write_cold_duration = $influxdb::params::cache_snapshot_write_cold_duration,
  $compact_full_write_old_duration    = $influxdb::params::compact_full_write_old_duration,
  $max_series_per_database            = $influxdb::params::max_series_per_database,
  $max_values_per_tag                 = $influxdb::params::max_values_per_tag,
  $udp_enable                         = $influxdb::params::udp_enable,
  $udp_bind_address                   = $influxdb::params::udp_bind_address,
  $graphite_enable                    = $influxdb::params::graphite_enable,
  $graphite_database                  = $influxdb::params::graphite_database,
  $graphite_listen                    = $influxdb::params::graphite_listen,
  $graphite_templates                 = $influxdb::params::graphite_templates

) inherits influxdb::params {
  case $split_client_package {
        true    : { $package_names = $influxdb_package_name }
        false   : { $package_names = [$influxdb_package_name[0]] }
        default : { fail('split_client_package package must be true (if using Debian/Ubuntu distro packages) or false') }
      }

  case $package {
    true    : { $ensure_package = 'present' }
    false   : { $ensure_package = 'purged' }
    latest  : { $ensure_package = 'latest' }
    default : { fail('package must be true, false or latest') }
  }

  case $service {
    true    : { $ensure_service = 'running' }
    false   : { $ensure_service = 'stopped' }
    running : { $ensure_service = 'running' }
    default : { fail('service must be true, false or running') }
  }

  if ($manage_repo == true) {
    class { 'influxdb::repos':
      apt_location          => $apt_location,
      apt_release           => $apt_release,
      apt_repos             => $apt_repos,
      apt_key               => $apt_key,
      influxdb_package_name => $package_names,
      influxdb_service_name => $influxdb_service_name,
    }

    case $::operatingsystem {
      /(?i:debian|devuan|ubuntu)/: {
        package { $package_names:
          ensure  => $ensure_package,
          require => [
            Class['influxdb::repos'],
            Exec['apt_update']
          ],
        }
      }
      /(?i:centos|fedora|redhat)/: {
        package { $package_names:
          ensure  => $ensure_package,
          require => [
            Class['influxdb::repos'],
            Exec['influxdb yum update']
          ],
        }
      }
      default                    : {
        fail("Module ${module_name} \
        is not supported on ${::operatingsystem}")
      }
    }

  }
  else {
    package { $package_names:
      ensure  => $ensure_package
    }
  }

  service { $influxdb_service_name:
    ensure     => $ensure_service,
    enable     => $enable,
    hasrestart => true,
    hasstatus  => true,
    provider   => $influxdb_service_provider,
    require    => Package[$package_names[0]],
  }

  if $ensure_service == 'running' {
      exec { 'wait_for_influxdb_to_listen':
        command   => 'influx -execute quit',
        unless    => 'influx -execute quit',
        tries     => '3',
        try_sleep => '10',
        require   => Service[$influxdb_service_name],
        path      => '/bin:/usr/bin',
      }

      if $http_auth_enabled {
        if $https_enable {
          $influx_init_cmd = 'influx -ssl -unsafeSsl'
        } else {
          $influx_init_cmd = 'influx'
        }
        exec { 'create_influxdb_admin_user':
          path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
          command => "${influx_init_cmd} -execute \
            \"CREATE USER ${admin_username} WITH PASSWORD '${admin_password}' WITH ALL PRIVILEGES\"",
          unless  => "${influx_init_cmd} \
            -username ${admin_username} -password '${admin_password}' -execute \
            'SHOW USERS' | tail -n+3 | awk '{print \$1}' | grep -x ${admin_username}",
          require =>  Exec['wait_for_influxdb_to_listen'],
          }
      }
  }

  file { '/etc/influxdb/influxdb.conf':
    ensure  => $ensure_package,
    path    => '/etc/influxdb/influxdb.conf',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('influxdb/influxdb.conf.erb'),
    require => Package[$influxdb_package_name[0]],
    notify  => Service[$influxdb_service_name],
  }
}
# EOF
