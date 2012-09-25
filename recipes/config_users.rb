#
# Cookbook Name:: gengine
# Recipe:: config_users
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

begin
  ::Dir.glob("#{node.gengine.repo.path}/users/*").each do |user|
    user = user.split('/')[-1]
    next if node.gengine.users.has_key? user
    node.default[:gengine][:users][user] = Hash.new
  end
rescue
end

# list of users already configured
users = Gengine::Config::list('qconf -suserl')

unless node.gengine.users.empty?
  node.default[:gengine][:files][:users] = "#{node.gengine.config}/users"
  directory node.gengine.files.users
end

node.gengine.users.each_pair do |name,attributes|

  config_file = "#{node.gengine.files.users}/#{name}" 

  mode = users.include?(name) ? 'M' : 'A'
  _command = "qconf -#{mode}user #{config_file} > /dev/null"
  execute _command do 
    command _command
    action :nothing
  end
  
  config = Gengine::Config::parse(node.gengine.defaults.user)
  config.merge!(Gengine::Config::read("#{node.gengine.repo.path}/users/#{name}"))
  config.merge!(attributes) unless attributes.empty?
  config['name'] = name
  
  file config_file do
    content Gengine::Config::create(config)
    notifies :run, "execute[#{_command}]", :immediately
  end
  
  users.delete(name)

end


