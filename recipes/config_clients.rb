#
# Cookbook Name:: gengine
# Recipe:: config_clients
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

# Search the Chef inventory for Grid Engine client nodes
if node.gengine.clients.has_key? 'search'
  if Chef::Config[:solo]
    Chef::Log.warn("[gengine::config_clients] Can't search for Grid Engine client nodes in solo mode!")
  else
    search(:node, node.gengine.clients[:search]) do |n|
      # add clients nodes to the list
      node.gengine.clients.nodes << n.name
    end
  end
end

# make sure that duplicates from all configuration sources get removed
node.gengine.clients.nodes.uniq!

# list of already know clients from the master
clients = Gengine::Config::list 'qconf -ss'

node.gengine.clients.nodes.each do |name|
  unless clients.include? name
    execute "qconf -as #{name}"
    execute "qconf -ah #{name}" if node.gengine.clients.admins
    Chef::Log.info("[gengine::config_clients] Node '#{name}' becomes a submit node.")
  end
  clients.delete name
end

# remove the queue master from the clients list
clients.delete node.gengine.master

# remove all exec nodes from the client list to make sure
# they don't get deleted
host_groups = Gengine::Config::list 'qconf -shgrpl'
host_groups.each do |name|
  `qconf -shgrp_resolved #{name}`.split.each do |node|
    clients.delete node
  end
end

clients.each do |name|
  execute "qconf -ds #{name}"
end

