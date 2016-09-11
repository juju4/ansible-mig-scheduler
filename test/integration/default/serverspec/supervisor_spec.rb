require 'serverspec'

# Required by serverspec
set :backend, :exec

## mig-scheduler can't be executed standalone (need rabbitmq)
describe service('supervisor'), :if => os[:family] == 'ubuntu' do
#  it { should be_enabled   }
#  it { should be_running   }
end  

describe service('supervisord'), :if => os[:family] == 'redhat' do
#  it { should be_enabled }	## FIXME! for some reason...
#  it { should be_running }
end

#describe command('supervisorctl status') do
#  its(:stdout) { should_not match /FATAL/ }
#  its(:stdout) { should_not match /unix:\/\/\/var\/run\/supervisor.sock no such file/ }
#  its(:exit_status) { should eq 0 }
#end

