#
# Cookbook: mesos-cluster
# License: Apache 2.0
#
# Copyright (C) 2015 Bloomberg Finance L.P.
#
node.default['mesos-cluster']['service_name'] = 'mesos-master'
include_recipe 'mesos-cluster::default'
