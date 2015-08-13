#
# Cookbook: mesos-cluster
# License: Apache 2.0
#
# Copyright (C) 2015 Bloomberg Finance L.P.
#
require 'poise_service/service_mixin'

module MesosClusterCookbook
  module Resource
    class MesosInstance < Chef::Resource 
      include Poise
      provides(:mesos_service)
      include PoiseService::ServiceMixin
      actions(:create)
      default_action(:create)

      # @!attribute instance
      # @return [String]
      attribute(:instance, kind_of: String, name_attribute: true)
    
      # @!attribute user
      # @return [String]
      attribute(:user, kind_of: String, default: 'mesos')
      # @!attribute group
      # @return [String]
      attribute(:group, kind_of: String, default: 'mesos')

      # Directory structure
      attribute(:config_dir
  
      # install_method - Choices of package or binary
      attribute(:install_method, equal_to: %w{package binary}, default: 'package')
      attribute(:package_name, kind_of: String, default: 'mesos')
      attribute(:package_version, kind_of: [String, NilClass], default: nil)

      # @!attribute type
      # @return [String]
      attribute(:type, equal_to: %w{master slave}, default: nil)

      # @!attribute zk
      # @return [Array]
      attribute(:zk, kind_of, String, required: true)

      # Mesos master settings
      attribute(:quorum, kind_of, [Integer, NilClass], default: nil)
      attribute(:work_dir, kind_of, String, default: '/var/lib/mesos')
      attribute(:cluster_name, kind_of, String, default: new_resource.instance)


      # !@attribute additional_options
      # @return [Hash]
      # This will be for all of the additional mesos settings that can be apart of the master or the slave
      attribute(:additional_options, option_collector: true)

    end
  end

  module Provider
    # @since 1.0.0
    class Chef::Provider::MesosService < Chef::Provider
      include Poise
      provides(:mesos_service)
      include PoiseService::ServiceMixin

      def action_create
        notifying_block do
          package new_resource.package_name do
            version new_resource.package_version unless new_resource.package_version.nil?
            action :upgrade
            only_if { new_resource.install_method == 'package' }
          end
          
          %w{mesos mesos-master mesos-slave}.each do |dir|
          directory dir do
            action :create
          end

          if new_resource.type == 'master'
            

          
        end

      end

      def action_enable
        notifying_block do
        end
        super
      end

      def action_disable
        notifying_block do

        end
        super
      end
    end
  end
end
