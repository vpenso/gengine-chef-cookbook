#
# Cookbook Name:: gengine
# Recipe:: install_exec
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

# all execution nodes are clients also!
include_recipe 'gengine::install_client'

case  node.platform
when 'debian','ubuntu'
  package 'gridengine-exec'
  service 'gridengine-exec' do
    pattern "sge_execd"
    stop_command "killall sge_execd"
    action [ :enable, :start ]
  end
end


