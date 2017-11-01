source 'https://rubygems.org'

puppetversion = \
  ENV.key?('PUPPET_VERSION') ? "= #{ENV['PUPPET_VERSION']}" : ['>= 3.3']

gem 'facter', '>= 1.7.0'
gem 'kitchen-docker_cli'
gem 'kitchen-puppet'
gem 'librarian-puppet'
gem 'puppet', puppetversion
gem 'puppet-lint', '>= 0.3.2'
gem 'puppetlabs_spec_helper', '>= 0.1.0'
gem 'test-kitchen'
