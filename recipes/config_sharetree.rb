#
# Cookbook Name:: gengine
# Recipe:: config_sharetree
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

# simple equal user sharetree policy
default = <<-EOF
id=0
name=Root
type=0
shares=1
childnodes=1
id=1
name=default
type=0
shares=1
childnodes=NONE
EOF

repository_file = "#{node.gengine.repo.path}/sharetree"
# where to store the active sharetree configuration
config_file = "#{node.gengine.config}/sharetree"
# execute sharetree configuration
_command = "qconf -Mstree #{config_file}"
execute _command do
  command _command
  action :nothing
end
# use a very simple default sharetree unless 
# overwritten by the configuration repository
file config_file do
  not_if do ::File.exists?(repository_file) end
  content default
  # trigger re-configuration on change
  notifies :run, "execute[#{_command}]", :immediately
end

# write the sharetree configuration file from the
# repository
template config_file do
  only_if do ::File.exists?(repository_file) end
  local true
  source repository_file
  # trigger re-configuration on change
  notifies :run, "execute[#{_command}]", :immediately
end



