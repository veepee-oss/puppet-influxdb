# == Class: influxdb::params
#
class influxdb::params {
  $libdir                  = '/var/lib/influxdb'

  $admin_enable            = false
  $admin_bind_address      = ':8083'

  $http_enable             = true
  $http_bind_address       = ':8086'
  $http_auth_enabled       = false
  $http_realm              = 'InfluxDB'
  $http_log_enabled        = true
  $https_enable            = false
  $http_bind_socket        = '/var/run/influxdb.sock'
  $max_series_per_database = '1000000'

  case $::operatingsystem {
    /(?i:debian|devuan|ubuntu)/: {
      $apt_location          = 'https://repos.influxdata.com/debian'
      $apt_release           = $::lsbdistcodename
      $apt_repos             = 'stable'
      $apt_key               = '05CE15085FC09D18E99EFB22684A14CF2582E0C5'
      $influxdb_package_name = 'influxdb'
      $influxdb_service_name = 'influxdb'
    }
    /(?i:centos|fedora|redhat)/: {
      $influxdb_package_name = 'influxdb'
      $influxdb_service_name = $::operatingsystemmajrelease ? {
        '6' => 'influxdb',
        '7' => 'influxd'
      }
    }
    default                    : {
      fail("Module ${module_name} \
      is not supported on ${::operatingsystem}")
    }
  }
}
# EOF
