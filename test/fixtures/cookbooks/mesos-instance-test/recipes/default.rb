mesos_instance "testing" do
  type "master"
  listen "127.0.0.1"
  port 5000
  quorum 1
  zk "zk:///127.0.0.1"
  additional_options do
    example "example"
    example2 "example2"
  end
end

