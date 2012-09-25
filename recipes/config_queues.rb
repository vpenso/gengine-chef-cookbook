#
# Cookbook Name:: gengine
# Recipe:: config_queues
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

node.default[:gengine][:files][:queues] = "#{node.gengine.config}/queues"

directory node.gengine.files.queues

# list of queues in the currently active configuration
queues = Array.new

# if queue configurations exist in the configuration repository
begin
  ::Dir.glob("#{node.gengine.repo.path}/queues/*").each do |queue|
    # file name matches queue name !!
    queue = queue.split('/')[-1] 
    # if queue is defined by attribtues already
    next if node.gengine.queues.has_key? queue
    # add to the list of queues to configure
    node.default[:gengine][:queues][queue] = Hash.new 
    # note that the actual configuration will be read in the loop further down
    Chef::Log.debug("[gengine] Queue #{queue} added from configuration repository.")
  end
rescue
end

if node.gengine.queues.empty?
  Chef::Log.warn("[gengine] No queues defined for this master!")
else
  # ask for currently configured queues
  queues = `qconf -sql 2>/dev/null`
  queues = queues.empty? ? Array.new : queues.split
  # iterate over all queues 
  node.gengine.queues.each do |name,attributes|
    # where to store (the potentially updated) the queue configuration
    config_file = "#{node.gengine.files.queues}/#{name}"
    # if queue exits run in modification mode
    mode = queues.include?(name) ? 'M' : 'A'
    # execute queue configuration command
    _command = "qconf -#{mode}q #{config_file}"
    execute _command do
      command _command
      # wait until triggered further down
      action :nothing
    end
    # read the default queue configuration part of this recipe
    config = Gengine::Config::parse node.gengine.defaults.queues
    # merge configuration from the repository (overwrites defaults)
    config.merge!(Gengine::Config::read("#{node.gengine.repo.path}/queues/#{name}"))
    # merge configuration from attributes (overwrites repository configuration)
    config.merge!(attributes)
    # set the queue name
    config["qname"] = name
    # write configuration to file 
    file config_file do
      content Gengine::Config::create(config)
      # trigger re-configuration if needed
      notifies :run, "execute[#{_command}]", :immediately
    end
    # remove queue from the list of current queues configured in GridEngine
    queues.delete(name)
  end
end
# remove queues still configured in GridEngine,
# but have been removed from the configuration
queues.each do |queue| 
  `qconf -dq #{queue} > /dev/null 2> /dev/null`
  Chef::Log.info("[gengine] Queue #{queue} removed from configuration.")
end
