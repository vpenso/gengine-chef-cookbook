#
# Cookbook Name:: gengine
# Recipe:: config_repository
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

directory node.gengine.repo.path do 
  recursive true
end

repository = git "#{node.gengine.repo.version} #{node.gengine.repo.url}" do
  repository node.gengine.repo.url
  destination node.gengine.repo.path
  reference node.gengine.repo.version
  ignore_failure true
  action :nothing
end

repository.run_action(:sync)
