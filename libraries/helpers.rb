module MesosCookbook
  module Helpers
    include Chef::DSL::IncludeRecipe

    def package_install
      case node.platform
      when 'ubuntu'
        bash 'add an apt trusted key for mesosphere' do
          code <<-EOH
          apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
          EOH
          action :run
        end

        bash 'add mesosphere repository' do
          code <<-EOH
          DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
          CODENAME=$(lsb_release -cs)
          echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" | sudo tee /etc/apt/sources.list.d/mesosphere.list
          sudo apt-get -y update
          EOH
          action :run
        end

        package 'mesos' do
          options '--no-install-recommends'
          action :upgrade
        end

      when 'centos'
        repo_url = value_for_platform(
          'centos' => {
            'default' => 'http://repos.mesosphere.io/el/6/noarch/RPMS/mesosphere-el-repo-6-2.noarch.rpm',
            '7.0.1406' => 'http://repos.mesosphere.io/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm'
          }
        )

        bash 'add mesosphere repository' do
          code <<-EOH
          rpm -Uvh #{repo_url} || true
          EOH
          action :run
        end

        package 'mesos' do
          action :upgrade
        end
      end
    end

    def config_dir_os
      case node.platform_family
      when 'ubuntu'
        '/etc/default'
      when 'rhel'
        '/etc/sysconfig'
      end
    end
  end
end
