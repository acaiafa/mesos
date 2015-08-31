require 'spec_helper'

describe_recipe 'mesos::default' do
  cached(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  it 'converges successfully' do
    chef_run
  end
end
