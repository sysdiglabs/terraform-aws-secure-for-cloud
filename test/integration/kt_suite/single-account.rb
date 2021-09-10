# frozen_string_literal: true
require 'awspec'
require 'aws-sdk'

# require 'Rhcl'

################
# This variable is hard coded as 'Kitchen' for use with github actions test
# because this is the default value in this terraform module test
# ##############
# In order to be used with customized test, replace 'kitchen' with your
# desired string
# If you are going to use custom 'tfvars', uncomment the following two lines
# Please, make sure you specified the use of this file in '.kitchen.yml'

# variable_file = File.read('test/fixtures/tf_module/test.tfvars')
# variable_file_hash = Rhcl.parse(variable_file)
# ##############
secure_cloud_name_prefix = "kitchen"

puts "Giving 10 minutes to ECS to deploy services correctly"
sleep 600
puts "Testing infrastructure"

describe "Testing Secure for Cloud ecs cluster number of services" do
  describe ecs_cluster(secure_cloud_name_prefix) do
    it { should exist }
    it { should be_active }
    its(:status) { should eq 'ACTIVE' }
    its(:running_tasks_count) { should eq 2 }
    its(:pending_tasks_count) { should eq 0 }
    its(:active_services_count) { should eq 2 }
  end
end

describe "Testing Code Build" do
  describe codebuild("#{secure_cloud_name_prefix}-BuildProject") do
    it { should exist }
  end
end
