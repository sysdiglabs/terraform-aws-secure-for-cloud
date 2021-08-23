# frozen_string_literal: true
require 'awspec'
require 'aws-sdk'
require 'json'
require 'Rhcl'

################
#     USING TFVARS
# replace test.tfvars with your tfvars file
# If you don't use tfvars, set 'secure_cloud_name_prefix' with the variable 'VAR.NAME' used on terraform
# and remove 'variable_file' and 'variable_file_hash'
################

variable_file = File.read('test.tfvars')
variable_file_hash = Rhcl.parse(variable_file)
secure_cloud_name_prefix = variable_file_hash['name']

cloudbench_role = "SysdigCloudBench"

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

describe "Test CloudBench role" do
  describe iam_role(cloudbench_role) do
    it { should exist }
  end
end
