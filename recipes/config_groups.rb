#
# Cookbook Name:: gengine
# Recipe:: config_groups
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

class Chef::Recipe
  include Gengine
end

repo_path = "#{node.gengine.repo.path}/groups/"

begin
  ::Dir.glob("#{repo_path}/*").each do |group|
    group = group.split('/')[-1]
    next if node.gengine.groups.has_key? group
    node.default[:gengine][:groups][group] = Hash.new
  end
rescue
end

groups = Gengine::Config::list('qconf -sul')

groups.delete 'arusers'
groups.delete 'defaultdepartment'
groups.delete 'deadlineusers'

unless node.gengine.groups.empty?
  node.default[:gengine][:files][:groups] = "#{node.gengine.config}/groups"
  directory node.gengine.files.groups
end

node.gengine.groups.each_pair do |name, attributes|

  config_file = "#{node.gengine.files.groups}/#{name}"

  mode = groups.include?(name) ? 'M' : 'A'
  _command = "qconf -#{mode}u #{config_file}"
  execute _command do
    command _command
    action :nothing
  end
  
  config = Gengine::Config::parse node.gengine.defaults.groups
  config.merge! Gengine::Config::read "#{repo_path}/groups/#{name}" 
  config.merge! attributes
  config['name'] = name

  file config_file do
    content Gengine::Config::create config
    notifies :run, "execute[#{_command}]", :immediately
  end

  groups.delete name

end

groups.each do |name|
  execute "qconf -dul #{name} > /dev/null 2> /dev/null"
end

