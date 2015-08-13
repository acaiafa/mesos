if defined?(ChefSpec)
  %i(create delete enable disable start stop restart).each do |action|
    define_method(:"#{action}_mesos_instance") do |resource_name|
      ChefSpec::Matchers::ResourceMatcher.new(:mesos_instance, action, resource_name)
    end
  end
end
