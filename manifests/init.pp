# == Class: influxdb
#
# Puppet module to install, deploy and configure influxdb.
#
class influxdb (
  $package                 = true,
  $service                 = true,
  $enable                  = true,
  $manage_repo             = true,
  $apt_location            = $influxdb::params::apt_location,
  $apt_release             = $influxdb::params::apt_release,
  $apt_repos               = $influxdb::params::apt_repos,
  $apt_key                 = $influxdb::params::apt_key,
  $influxdb_package_name   = $influxdb::params::influxdb_package_name,
  $influxdb_service_name   = $influxdb::params::influxdb_service_name,
  # daemon settings
  $hostname                = $::fqdn,
  $libdir                  = $influxdb::params::libdir,
  $admin_enable            = $influxdb::params::admin_enable,
  $admin_bind_address      = $influxdb::params::admin_bind_address,
  $admin_username          = $influxdb::params::admin_username,
  $admin_password          = $influxdb::params::admin_password,
  $domain_name             = $influxdb::params::domain_name,
  $http_enable             = $influxdb::params::http_enable,
  $http_bind_address       = $influxdb::params::http_bind_address,
  $http_auth_enabled       = $influxdb::params::http_auth_enabled,
  $http_realm              = $influxdb::params::http_realm,
  $http_log_enabled        = $influxdb::params::http_log_enabled,
  $https_enable            = $influxdb::params::https_enable,
  $http_bind_socket        = $influxdb::params::http_bind_socket,
  $logging_format          = $influxdb::params::logging_format,
  $logging_level           = $influxdb::params::logging_level,
  $max_series_per_database = $influxdb::params::max_series_per_database,
  $max_values_per_tag      = $influxdb::params::max_values_per_tag,
  $udp_enable              = $influxdb::params::udp_enable,
  $udp_bind_address        = $influxdb::params::udp_bind_address

) inherits influxdb::params {
  case $package {
    true    : { $ensure_package = 'present' }
    false   : { $ensure_package = 'purged' }
    latest  : { $ensure_package = 'latest' }
    default : { fail('package must be true, false or lastest') }
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
      influxdb_package_name => $influxdb_package_name,
      influxdb_service_name => $influxdb_service_name,
    }

    package { $influxdb_package_name:
      ensure  => $ensure_package,
      require => Class['influxdb::repos'],
    }
  }
  else {
    package { $influxdb_package_name:
      ensure  => $ensure_package,
    }
  }

  service { $influxdb_service_name:
    ensure     => $ensure_service,
    enable     => $enable,
    hasrestart => true,
    hasstatus  => true,
    require    => Package[$influxdb_package_name],
  }

  file { '/etc/influxdb/influxdb.conf':
    ensure  => $ensure_package,
    path    => '/etc/influxdb/influxdb.conf',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('influxdb/influxdb.conf.erb'),
    require => Package[$influxdb_package_name],
    notify  => Service[$influxdb_service_name],
  }
}
# EOF
