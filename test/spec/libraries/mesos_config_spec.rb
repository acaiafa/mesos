require 'poise_boiler/spec_helper'
require_relative '../../../libraries/mesos_config'

describe MesosClusterCookbook::Resource::MesosConfig do
  step_into(:mesos_config)
  context '#action_create' do
    recipe do
      mesos_config '/etc/mesos'
    end
  end

  context '#action_delete' do
    mesos_config '/etc/mesos' do
      action :delete
    end
  end
end
