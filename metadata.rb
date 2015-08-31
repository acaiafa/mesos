name 'mesos'
maintainer 'Anthony Caiafa'
maintainer_email 'acaiafa1@bloomberg.net'
description 'Installs/Configures mesos'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.0.0'

supports 'redhat', '>= 5.8'
supports 'centos', '>= 5.8'
supports 'ubuntu', '>= 12.04'

depends 'poise', '~> 2.2'
depends 'poise-service', '~> 1.0'
