mesos_instance "testing" do
  type "master"
  listen "127.0.0.1"
  port 5000
  quorum 1
  zk "zk:///whatitdo"
  additional_options do
    something "something else"
    something2 "something else2"
  end
end

