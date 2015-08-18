# /usr/bin/mesos-init-wrapper READ THIS FILE... YOU CAN SET PORT AS AN ENV VAR OR CLI OPTION IT MAKES NO DIFFERNCE SAME GOES FOR ALL THIS BULLSHIT PLEASE LOOK AT THIS BREAK THIS OUT INTO MESOS_MASTER MESOS_SLAVE CONFIGS MAYBE?
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

      # @!attribute instance
      # @return [String]
      attribute(:instance, kind_of: String, name_attribute: true)

      # @!attribute cookbook
      # @return [String]
      attribute(:cookbook, kind_of: String, default: 'mesos-cluster')

      # @!attribute user
      # @return [String]
      attribute(:user, kind_of: String, default: 'mesos')
      # @!attribute group
      # @return [String]
      attribute(:group, kind_of: String, default: 'mesos')

      # install_method - Choices of package or binary
      attribute(:install_method, equal_to: %w{package binary}, default: 'package')
      attribute(:package_name, kind_of: String, default: 'mesos')
      attribute(:package_version, kind_of: [String, NilClass], default: nil)

      # @!attribute listen_ip
      # @return [String]
      attribute(:listen_ip, kind_of: String, default: '0.0.0.0')

      # @!attribute port
      # @return [Integer]
      attribute(:port, kind_of, Integer, default: 5050)
 
      # @!attribute log_dir
      # @return [String]
      attribute(:log_dir, kind_of: String, default: '/var/log/mesos')

      # @!attribute mesos_ulimit
      # @return [Integer]
      attribute(:mesos_ulimit, kind_of: Integer, default: 8192)

      # Directory structure
      attribute(:config_dir, kind_of: String, default: '/etc/mesos')
      attribute(:master_config_dir, kind_of: String, default: '/etc/mesos-master')
      attribute(:slave_config_dir, kind_of: String, default: '/etc/mesos-slave')

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

      # Mesos Slave Settings
      attribute(:isolation, kind_of, [String, NilClass], default: nil)



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
            directory "#{new_resource.instance} :create #{new_resource.config_dir}/#{dir}" do
              action :create
            end

            # Create Zk connection string
            template "#{config_dir}/zk" do
              cookbook new_resource.cookbook
              source 'etc/mesos/zk.erb'
              owner new_resource.user
              group new_resource.group
              variables(zk: new_resource.zk)
            end

            # Create default mesos file
            template "#{new_resource.instance} :create /etc/default/mesos" do
              cookbook new_resource.cookbook
              source 'etc/default/mesos.erb'
              owner new_resource.user
              group new_resource.group
              variables(
                config: new_resource,
                log_dir: new_resource.log_dir,
                mesos_ulimit: new_resource.mesos_ulimit
              )
            end


            # Mesos master specific settings
            if new_resource.type == 'master'
              %w{cluster quorum}.each do |c|
                template "#{new_resource.instance} :create #{config_dir_master}/#{c}" do
                  cookbook new_resource.cookbook
                  source "etc/mesos-master/#{c}.erb"
                  owner new_resource.user
                  group new_resource.group
                  varibables(
                    quroum: new_resource.quroum,
                    clustername: new_resource.clustername
                  )
                end
              end

              template "#{new_resource.instance} :create /etc/default/mesos-master" do
                cookbook new_resource.cookbook
                source 'etc/mesos-master/mesos-master.erb'
                owner new_resource.user
                group new_resource.group
                variables(
                  config: new_resource,
                  port: new_resource.port
                )
              end

              execute 'slave_off' do
                command 'echo manual >> /etc/init/mesos-slave.override'
              end

            elsif new_resource.type == 'slave'
              template "#{new_resource.instance} :create #{config_dir_slave}/isolation"
              cookbook new_resource.cookbook
              source "etc/mesos-slave/isolation.erb"
              owner new_resource.user
              group new_resource.group
              cookbook new_resource.cookbook
              variables(isolation: new_resource.isolation)
            end

            template "#{new_resource.instance} :create /etc/default/mesos-slave" do
              cookbook new_resource.cookbook
              source 'etc/mesos-master/mesos-slave.erb'
              owner new_resource.user
              group new_resource.group
              variables(config: new_resource)
            end

          end
        end
        super 
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
