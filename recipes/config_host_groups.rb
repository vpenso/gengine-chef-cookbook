#
# Cookbook Name:: gengine
# Recipe:: config_host_groups
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

node.default[:gengine][:files][:host_groups] = "#{node.gengine.config}/host_groups"

if node.gengine.host_groups.empty?
  Chef::Log.warn("[gengine] No host group(s) defined for GridEngine queue master!")
else
  directory node.gengine.files.host_groups
  # collects a list go all execution nodes from all host groups
  execution_nodes = Array.new
  # iterate over all defined host groups
  node.gengine.host_groups.each_pair do |name,attributes|
    # store the host group configuration file in the file-system
    host_group_file = "#{node.gengine.files.host_groups}/#{name}"
    # run in modification mode if host group exists already
    mode = `qconf -shgrpl`.split.include?("@#{name}") ? 'M' : 'A'
    # run host group configuration command of GridEngine passing a file as source
    _command = "qconf -#{mode}hgrp #{host_group_file}"
    execute _command do
      command _command
      action :nothing
    end
    # list of exec nodes belonging to this group
    host_group = Array.new
    # add nodes defined by attributes 
    host_group = host_group + attributes[:nodes] if attributes.has_key? 'nodes'
    # search for execution nodes by query defined as attribute
    if  Chef::Config[:solo] and attributes.has_key? 'search'
      Chef::Log.warn("[gengine] Can't search for GridEngine execution nodes in solo mode!")
    end
    unless Chef::Config[:solo]
      if attributes.has_key? 'search'
        count = 0
        search(:node, attributes[:search]) do |node|
          host_group << node.name
          count += 1
        end
      end
    end
    # if configuration repository exists?
    unless node.gengine.repo.url.empty?
      repo_file = "#{node.gengine.repo.path}/host_groups/#{name}"
      if ::File.exists? repo_file
        nodes = File.readlines(repo_file)[1].split
        host_group = host_group + nodes[1..-1]
      end
    end
    # make sure to remove duplicate nodes
    host_group.uniq!
    execution_nodes = execution_nodes + host_group
    # handle host group without nodes
    host_group << 'NONE' if host_group.empty?
    # write the host group file
    template host_group_file do
      source 'host_group.erb'
      variables( :name => "@#{name}", :host_group => host_group )
      # trigger re-configuration on change
      notifies :run, "execute[#{_command}]", :immediately
    end
    # only for host groups containing nodes
    unless host_group[0] == 'NONE'
      # if execution nodes can act as job submit-hosts (aka clients)
      if attributes.has_key? 'client' and attributes[:client] 
        # get the list of known submit nodes
        submitters = `qconf -ss`.split
        host_group.each do |node|
          unless submitters.include? node
            `qconf -as #{node} > /dev/null`
            Chef::Log.info("GridEngine execution node #{node} becomes a submit node")
          end
        end
      end
      # are there resource attributes definitions for this host group?
      if attributes.has_key? 'resources'
        # store the resource attributes  configuration file in the file-system
        host_group_resources_file = "#{node.gengine.files.host_groups}/#{name}_resources"
        # list of all resources for this host group
        resources = Array.new
        attributes[:resources].each_pair do |key,value|
          resources << "#{key} #{value}"
        end
        unless resources.empty?
          # configure host resource attributes for host group
          _script = "qconf -Mattr exechost #{host_group_resources_file} $node"
          script _script do
            interpreter 'bash'
            user 'root'
            # iterate over all nodes in host group and let GridEngine apply the resource attributes
            code <<-EOH
              for node in #{host_group.join(' ')}
              do
                #{_script}
              done
            EOH
            action :nothing
          end
          # write the resource configuration to file
          file host_group_resources_file do
            content resources.join("\n")
            # trigger configuration run on change
            notifies :run, "script[#{_script}]", :immediately
          end
        end
      end
    end
  end
  # make sure to remove execution nodes nod configured 
  `qconf -sel`.split.each do |node|
    unless execution_nodes.include? node
      `qconf -de #{node} > /dev/null`
      Chef::Log.info("[gengine] Execution node #{node} removed from GridEngine")
    end
  end
end
