#
# Cookbook: mesos-cluster
# License: Apache 2.0
#
# Copyright (C) 2015 Bloomberg Finance L.P.
#
default['mesos-cluster']['service_name'] = 'mesos-slave'
default['mesos-cluster']['service_user'] = 'mesos'
default['mesos-cluster']['service_group'] = 'mesos'

default['mesos-cluster']['config']['path'] = '/etc/mesos/mesos.properties'

default['mesos-cluster']['service']['version'] = '0.22.1'
default['mesos-cluster']['service']['install_method'] = 'package'
