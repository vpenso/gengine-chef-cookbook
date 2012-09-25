#
# Cookbook Name:: gengine
# Recipe:: config_complex_values
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

class Chef::Recipe
  include Gengine
end

# parse default configuration from above
config = Gengine::Config::parse node.gengine.defaults.complex_values
# merge configuration from the repository (overwrites defaults)
config.merge!(Gengine::Config::read("#{node.gengine.repo.path}/complex_values"))
# merge configuration from the repository (overwrites defaults)
config.merge!(node.gengine.complex_values) unless node.gengine.complex_values.empty?

config_file = "#{node.gengine.config}/complex_values"

_command = "qconf -Mc #{config_file}"
execute _command do
  command _command
  action :nothing
end

file config_file do
  content Gengine::Config::create(config)
  notifies :run, "execute[#{_command}]", :immediately
end



