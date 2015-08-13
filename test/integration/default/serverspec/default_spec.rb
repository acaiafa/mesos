require 'spec_helper'

describe service('mesos') do
  it { should be_enabled }
  it { should be_running }
end
