# -*- ruby -*-

require 'serverspec'

set :backend, :exec

describe 'Packages' do
  describe package('influxdb') do
    it { should be_installed }
  end
end

describe 'Service' do
  describe service('influxdb') do
    it { should be_running }
  end
end

describe 'Configuration files' do
  describe file('/etc/influxdb/influxdb.conf') do
    it { should exist }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_mode 644 }
  end
end

describe 'Databases creation' do
  describe command('influx -execute "SHOW DATABASES" | grep -x test') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match /test/ }
  end
end
# EOF
