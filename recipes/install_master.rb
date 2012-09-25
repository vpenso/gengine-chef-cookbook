#
# Cookbook Name:: gengine
# Recipe:: install_master
#
# Copyright 2012, Victor Penso
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

case  node.platform
when 'debian','ubuntu'
  package 'git-core'
  package 'gridengine-master'
  service 'gridengine-master' do
    supports :restart => true, :'force-reload' => true
  end
end

# tell recipe "install_client" that the master is local
node.default[:gengine][:master] = node.fqdn
# install and configure the client on the master
include_recipe "gengine::install_client"
node.default[:gengine][:clients] << node.fqdn
# queue master configuration from an external Git repository
include_recipe 'gengine::config_repository' unless node.gengine.repo.url.empty?
# Several runs will be needed to configuration the master!
if ::File.exists? node.gengine.config
  # the correct order is important here!
  include_recipe 'gengine::config_global'
  include_recipe 'gengine::config_complex_values'
  include_recipe 'gengine::config_scheduler'
  include_recipe 'gengine::config_groups'
  include_recipe 'gengine::config_projects'
  include_recipe 'gengine::config_users'
  include_recipe 'gengine::config_sharetree'
  include_recipe 'gengine::config_parallel_environments'
  include_recipe 'gengine::config_quotas'
  include_recipe 'gengine::config_host_groups'
  include_recipe 'gengine::config_queues'
  include_recipe 'gengine::config_clients'
else
  log("Configuration of GridEngine queue master not finished yet!") { level :warn }
end

