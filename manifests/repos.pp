# == Class: influxdb::repos
#
# This is a container class holding default parameters for influxdb module.
#
class influxdb::repos (
  $apt_location          = $influxdb::params::apt_location,
  $apt_release           = $influxdb::params::apt_release,
  $apt_repos             = $influxdb::params::apt_repos,
  $apt_key               = $influxdb::params::apt_key,
  $influxdb_package_name = $influxdb::params::influxdb_package_name,
  $influxdb_service_name = $influxdb::params::influxdb_service_name
) inherits influxdb::params {
  case $::operatingsystem {
    /(?i:debian|devuan|ubuntu)/: {
      case $::lsbdistcodename {
        /(buster|n\/a)/   : {
          if !defined(Class['apt']) {
            include apt
          }

          apt::source { 'influxdb':
            ensure      => present,
            location    => $apt_location,
            release     => 'jessie',
            repos       => 'stable',
            key         => $apt_key,
            include_src => false,
          }
        }
        default : {
          if !defined(Class['apt']) {
            include apt
          }

          apt::source { 'influxdb':
            ensure      => present,
            location    => $apt_location,
            release     => $apt_release,
            repos       => $apt_repos,
            key         => $apt_key,
            include_src => false,
          }
        }
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
