# -*- ruby -*-

require 'serverspec'

set :backend, :exec

describe 'Packages' do
  describe package('influxdb') do
    it { should be_installed }
  end
end

# TODO
# describe 'Service' do
#   describe service('influxdb') do
#     it { should be_running }
#   end
# end

describe 'Configuration files' do
  describe file('/etc/influxdb/influxdb.conf') do
    it { should exist }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_mode 644 }
  end
end
# EOF
