#
# Cookbook Name:: gengine
# Recipe:: config_quotas
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

# find all quota definitions in configuration repository
repo_path = "#{node.gengine.repo.path}/quotas"
begin
  ::Dir.glob("#{repo_path}/*").each do |file|
    # quota name similar to file name!
    name = file.split('/')[-1]
    # don't overwrite already defined quotas
    if node.gengine.quotas.has_key? name
      Chef::Log.warn("[gengine] Ignoring quota defintion '#{name}' from repository!")
      next
    end
    # read quota definition from repository file
    attributes = { 'limits' => Array.new }
    ::File.readlines(file).each do |line|
      line = line.lstrip
      case line
      when %r{description}
        attributes['description'] = line.gsub(/^description/,'').lstrip.chop
      when %r{limit}
        attributes['limits'] << line.gsub(/^limit/,'').lstrip.chop
      when %r{enabled}
        attributes['enabled'] = line.gsub(/^enabled/,'').lstrip.chop
      end
    end
    # add quota definition to configuration attribtues
    node.default[:gengine][:quotas][name] = attributes
  end
end

config_file = "#{node.gengine.config}/quotas"

_command = "qconf -Mrqs #{config_file}"
execute _command do
  command _command
  action :nothing
end

quotas = String.new

# iterate over all quot definitons
node.gengine.quotas.each_pair do |name,attributes|

  unless attributes.has_key? 'description'
    Chef::Log.warn("[gengine] Quota #{name} has no description!")
    next
  end

  quota = <<-EOF
    name #{name}
    description "#{attributes[:description]}"
  EOF

  # quotas are enabled by default
  enabled = 'TRUE'
  enabled = attributes[:enabled] if attributes.has_key? 'enabled'
  quota << "    enabled #{enabled}\n"
  
  # omit quotas without limits
  unless attributes.has_key? 'limits' and not attributes[:limits].empty?
    Chef::Log.warn("[gengine] Quota #{name} has no limits defined!")
    next
  end
  # add all limits to this quota definition
  attributes[:limits].each do |limit|
    quota << "    limit #{limit}\n"
  end

  # add quota to the list of all quotas
  quotas << "{\n#{quota}}\n"

end

file config_file do
  content quotas
  notifies :run, "execute[#{_command}]", :immediately
end
