name 'mesos'
maintainer 'John Bellone'
maintainer_email 'jbellone@bloomberg.net'
license 'Apache 2.0'
description 'Application cookbook for installing and configuring a Mesos cluster.'
version '1.0.0'

supports 'ubuntu', '>= 12.04'
supports 'centos', '>= 6.6'
supports 'redhat', '>= 6.6'

depends 'poise', '~> 2.0'
depends 'poise-service', '~> 1.0'
