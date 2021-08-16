# == Class: influxdb::params
#
class influxdb::params {
  $libdir                             = '/var/lib/influxdb'
  $admin_enable                       = false
  $admin_bind_address                 = '0.0.0.0:8083'
  $admin_username                     = 'admin'
  $admin_password                     = undef
  $domain_name                        = undef
  $flux_enable                        = false
  $http_enable                        = true
  $http_bind_address                  = '0.0.0.0:8086'
  $http_auth_enabled                  = false
  $http_realm                         = 'InfluxDB'
  $http_log_enabled                   = true
  $https_enable                       = false
  $http_socket_enable                 = false
  $http_bind_socket                   = '/var/run/influxdb.sock'
  $logging_format                     = 'auto'
  $logging_level                      = 'info'
  $index_version                      = undef
  $cache_max_memory_size              = '1048576000'
  $cache_snapshot_memory_size         = '26214400'
  $cache_snapshot_write_cold_duration = '10m'
  $compact_full_write_old_duration    = '4h'
  $max_series_per_database            = '1000000'
  $max_values_per_tag                 = '100000'
  $udp_enable                         = false
  $udp_bind_address                   = '0.0.0.0:8089'
  $graphite_enable                    = false
  $graphite_database                  = 'graphite'
  $graphite_listen                    = ':2003'
  $graphite_templates                 = [
    '*.app env.service.resource.measurement',
    'server', # default template
  ]
  $default_retention_duration         = undef

  case $::operatingsystem {
    /(?i:debian|devuan|ubuntu)/: {
      $apt_location              = 'https://repos.influxdata.com/debian'
      $apt_release               = $::lsbdistcodename
      $apt_repos                 = 'stable'
      $apt_key                   = '05CE15085FC09D18E99EFB22684A14CF2582E0C5'
      $influxdb_package_name     = ['influxdb', 'influxdb-client']
      $influxdb_service_name     = 'influxdb'
      $influxdb_service_provider = $::operatingsystemmajrelease ? {
        '14.04' => 'debian',
        default => 'systemd'
      }
    }
    /(?i:centos|fedora|redhat)/: {
      $influxdb_package_name = ['influxdb']
      $influxdb_service_name = $::operatingsystemmajrelease ? {
        '6' => 'influxdb',
        '7' => 'influxd',
        '8' => 'influxd'
      }
      $influxdb_service_provider = $::operatingsystemmajrelease ? {
        '6' => 'redhat',
        '7' => 'systemd',
        '8' => 'systemd'
      }
    }
    default                    : {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }
}
# EOF
