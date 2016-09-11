require 'serverspec'

## Required by serverspec
set :backend, :exec

describe file('/home/_mig/go/src/mig.ninja/mig/bin/linux/amd64/mig-scheduler') do
  it { should be_file }
  it { should be_executable }
end

describe file('/etc/mig/scheduler.cfg') do
  it { should be_file }
end

## can't test without rabbitmq server
#describe process("mig-scheduler") do
#  its(:user) { should eq "root" }
#end
