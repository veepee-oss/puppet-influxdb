# == Class: influxdb::repos
#
# This is a container class holding default parameters for influxdb module.
#
class influxdb::repos (
  $location              = $influxdb::params::location,
  $release               = $influxdb::params::release,
  $repos                 = $influxdb::params::repos,
  $key                   = $influxdb::params::key,
  $influxdb_package_name = $influxdb::params::influxdb_package_name,
  $influxdb_service_name = $influxdb::params::influxdb_service_name
) inherits influxdb::params {
  case $::operatingsystem {
    /(?i:debian|devuan|ubuntu)/: {
      if !defined(Class['apt']) {
        include apt
      }

      apt::source { 'influxdb':
        ensure      => present,
        location    => $location,
        release     => $release,
        repos       => $repos,
        key         => $key,
        include_src => false,
      }
    }
    /(?i:centos|fedora|redhat)/: {
      file { '/etc/yum.repos.d/influxdb.repo':
        ensure  => present,
        backup  => true,
        content => template('influxdb/influxdb.repo.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
      }

      exec { 'influxdb yum update':
        command   => 'yum update -q -y',
        path      => [ '/usr/bin', '/usr/sbin', '/bin', '/sbin' ],
        subscribe => File['/etc/yum.repos.d/influxdb.repo'],
      }
    }
    default                    : {
      fail("Module ${module_name} \
      is not supported on ${::operatingsystem}")
    }
  }
}
# EOF
