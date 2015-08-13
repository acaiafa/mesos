require 'spec_helper'

describe_recipe 'mesos::default' do
  cached(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  context 'with default attributes' do
    it { expect(chef_run).to include_recipe('java::default') }
    it { expect(chef_run).to create_mesos_config('mesos').with(user: 'mesos', group: 'mesos') }
    it { expect(chef_run).to enable_mesos_service('mesos').with(user: 'mesos', group: 'mesos') }

    it 'converges successfully' do
      chef_run
    end
  end
end
