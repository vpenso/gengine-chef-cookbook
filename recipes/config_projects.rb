#
# Cookbook Name:: gengine
# Recipe:: config_projects
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

repo_path = "#{node.gengine.repo.path}/projects"

begin
  ::Dir.glob("#{repo_path}/*").each do |project|
    project = project.split('/')[-1]
    next if node.gengine.projects.has_key? project
    node.default[:gengine][:projects][project] = Hash.new
  end
rescue
end


projects = Gengine::Config::list('qconf -sprjl')

unless node.gengine.projects.empty?
  node.default[:gengine][:files][:projects] = "#{node.gengine.config}/projects"
  directory node.gengine.files.projects
end

node.gengine.projects.each_pair do |name,attributes|
  
  config_file = "#{node.gengine.files.projects}/#{name}"

  mode = projects.include?(name) ? 'M' : 'A'
  _command = "qconf -#{mode}prj #{config_file}"
  execute _command do
    command _command
    action :nothing
  end

  config = Gengine::Config.parse node.gengine.defaults.projects
  config.merge! attributes
  config['name'] = name

  file config_file do
    content Gengine::Config::create config
    notifies :run, "execute[#{_command}]", :immediately
  end

  projects.delete name
end

projects.each do |name|
  execute "qconf -dprj #{name} > /dev/null 2> /dev/null"
end
