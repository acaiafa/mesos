# Cookbook: mesos
# License: Apache 2.0
#
# Copyright (C) 2015 Bloomberg Finance L.P.
#
require 'poise_service/service_mixin'
require_relative 'helpers'

module MesosCookbook
  module Resource
    class MesosInstance < Chef::Resource
      include Poise
      provides(:mesos_instance)
      include PoiseService::ServiceMixin
      include MesosCookbook::Helpers

      # @!attribute instance
      # @return [String]
      attribute(:instance, kind_of: String, name_attribute: true)

      # @!attribute cookbook
      # @return [String]
      attribute(:cookbook, kind_of: String, default: 'mesos')

      # @!attribute source
      # @return [String]
      attribute(:source, kind_of: [String, NilClass], default: nil)

      # @!attribute user
      # @return [String]
      attribute(:user, kind_of: String, default: 'root')
      # @!attribute group
      # @return [String]
      attribute(:group, kind_of: String, default: 'root')

      # install_method - Choices of package or binary
      attribute(:install_method, equal_to: %w{package binary}, default: 'package')
      attribute(:package_name, kind_of: String, default: 'mesos')
      attribute(:package_version, kind_of: [String, NilClass], default: nil)

      # @!attribute listen_ip
      # @return [String]
      attribute(:listen, kind_of: String, default: '0.0.0.0')

      # @!attribute port
      # @return [Integer]
      attribute(:port, kind_of: Integer, default: 5050)

      # @!attribute log_dir
      # @return [String]
      attribute(:log_dir, kind_of: String, default: '/var/log/mesos')

      # @!attribute mesos_ulimit
      # @return [Integer]
      attribute(:mesos_ulimit, kind_of: Integer, default: 8192)

      # Directory structure
      attribute(:config_dir, kind_of: String, default: '/etc/mesos')
      attribute(:config_dir_master, kind_of: String, default: '/etc/mesos-master')
      attribute(:config_dir_slave, kind_of: String, default: '/etc/mesos-slave')

      # @!attribute type
      # @return [String]
      attribute(:type, equal_to: %w{master slave}, default: nil)

      # @!attribute zk
      # @return [String]
      attribute(:zk, kind_of: [String, NilClass], default: nil, required: true)

      # Mesos master settings
      attribute(:quorum, kind_of: [Integer, NilClass], default: nil)
      attribute(:work_dir, kind_of: String, default: '/var/lib/mesos')
      attribute(:cluster_name, kind_of: String)

      # !@attribute additional_options
      # @return [Hash]
      # This will be for all of the additional mesos settings that can be apart of the master or the slave
      attribute(:additional_options, option_collector: true)

    end
  end

  module Provider
    # @since 1.0.0
    class MesosInstance < Chef::Provider
      include Poise
      provides(:mesos_instance)
      include PoiseService::ServiceMixin
      include MesosCookbook::Helpers

      def action_enable
        notifying_block do
          package_install
          package new_resource.package_name do
            options "--no-install-recommends"
            version new_resource.package_version unless new_resource.package_version.nil?
            action :upgrade
            only_if { new_resource.install_method == 'package' }
          end

          [new_resource.config_dir, new_resource.config_dir_master, new_resource.config_dir_slave].each do |dir|
            directory "#{new_resource.instance} :create #{dir}" do
              recursive true
              action :create
            end
          end

          # Create Zk connection string
          template "#{new_resource.config_dir}/zk" do
            cookbook new_resource.cookbook
            source 'etc/mesos/zk.erb'
            owner new_resource.user
            group new_resource.group
            variables(zk: new_resource.zk)
          end

          # Create default mesos file
          template "#{new_resource.instance} :create #{config_dir_os}/mesos" do
            path "#{config_dir_os}/mesos"
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

          def create_additional_options
            type_dir = new_resource.send('config_dir_' + new_resource.type) 
            new_resource.additional_options.each do |k,v|
              file "#{new_resource.instance} :create #{type_dir})/#{k}" do
                path "#{type_dir}/#{k}"
                content "#{v}"
              end
            end
          end

          # Mesos master specific settings
          if new_resource.type == 'master'
            %w{cluster quorum}.each do |c|
              template "#{new_resource.instance} :create #{new_resource.config_dir_master}/#{c}" do
                cookbook new_resource.cookbook
                path "#{new_resource.config_dir_master}/#{c}"
                source "etc/mesos-master/#{c}.erb"
                owner new_resource.user
                group new_resource.group
                variables(
                  config: new_resource,
                  quorum: new_resource.quorum,
                  cluster_name: new_resource.instance
                )
              end
            end

            template "#{new_resource.instance} :create #{config_dir_os}/mesos-master" do
              cookbook new_resource.cookbook
              path "#{config_dir_os}/mesos-master"
              source 'etc/default/mesos-master.erb'
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
            template "#{new_resource.instance} :create #{config_dir_os}/mesos-slave" do
              cookbook new_resource.cookbook
              path "#{config_dir_os}/mesos-slave"
              source 'etc/me/mesos-slave.erb'
              owner new_resource.user
              group new_resource.group
              variables(config: new_resource)
            end

            execute 'master_off' do
              command 'echo manual >> /etc/init/mesos-master.override'
            end
          end
          create_additional_options
        end
        super
      end

      def service_options(service)
        service.service_name("mesos-#{new_resource.type}")
        service.command("/usr/bin/mesos-init-wrapper #{new_resource.type}")
        service.restart_on_update(true)
      end
    end
  end
end
