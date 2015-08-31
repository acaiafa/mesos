# Mesos Cookbook
[![License](https://img.shields.io/badge/license-Apache_2-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

[Application cookbook][0] which installs and configures [mesos][1]. This cookbook does not install zookeeper for you. I specifically remove it from the dependency install since I don't think its heplful for mesos to install this for you. You can use this cookbook [zookeeper-cluster][2] to setup and install zookeeper.

## Usage
### Supports
- Ubuntu
- CentOS

### Dependencies
| Name | Description |
|------|-------------|
| [poise][2] | [Library cookbook][4] built to aide in writing reusable cookbooks. |
| [poise-service][3] | [Library cookbook][4] built to abstract service management. |

### Attributes
The current attributes are the bare minimum to get the service up and running. This whole cookbook assumes you understand mesos and its components. There is an option collector which will create files(key) and write the options(value) into the directory of the instance(master/slave). 

### Resources/Providers

#### mesos_instance
A single mesos instance would look like this. 

```ruby
mesos_instance "testing" do
  type "master" # you can do master/slave/standalone
  listen "172.16.10.10"
  port 5000
  quorum 1
  zk "zk:///172.16.10.10"
  additional_options do
    example "example" # will create /etc/mesos-master/example, which contains example in the file
    example2 "example2" # will create /etc/mesos-master/example2, which contains example2 in the file
  end
end
```

License & Authors
-----------------
- Author:: Anthony Caiafa (<acaiafa1@bloomberg.net>)

```text
Copyright 2015 Bloomberg Finance L.P.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

[0]: http://blog.vialstudios.com/the-environment-cookbook-pattern#theapplicationcookbook
[1]: http://mesos.apache.org/documentation/latest/configuration/
[2]: https://github.com/bloomberg/zookeeper-cookbook/
[2]: https://github.com/poise/poise
[3]: https://github.com/poise/poise-service
[4]: http://blog.vialstudios.com/the-environment-cookbook-pattern#thelibrarycookbook
