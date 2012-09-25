#
# Cookbook Name:: gengine
# Recipe:: config_parallel_environments
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


# if parallel environment configuration exist in repository
begin
  ::Dir.glob("#{node.gengine.repo.path}/parallel_environments/*").each do |parallel_env|
    # file name matches parallel environment name!!
    parallel_env = parallel_env.split('/')[-1]
    next if node.gengine.parallel_environments.has_key? parallel_env
    # add to configuration list if not existing yet
    node.default[:gengine][:parallel_environments][parallel_env] = Hash.new
    Chef::Log.debug("[gengine] Parallel environment '#{parallel_env}' added from configuration repository")
  end
rescue
end

unless node.gengine.parallel_environments.empty?

  # directory storing configurations for parallel environments
  node.default[:gengine][:files][:parallel_environments] = "#{node.gengine.config}/parallel_environments"
  directory node.gengine.files.parallel_environments
  # list of existing parallel environments
  parallel_environments = `qconf -spl 2> /dev/null`
  parallel_environments = parallel_environments.empty? ? Array.new : parallel_environments.split
  # iterate over all defined parallel environments
  node.gengine.parallel_environments.each_pair do |name,attribtues|
    # where to store (the potentially updated) parallel environment configuration
    config_file = "#{node.gengine.files.parallel_environments}/#{name}"
    # if parallel environment exits run in modification mode
    mode = parallel_environments.include?(name) ? 'M' : 'A'
    # execute parallel environment configuration
    _command = "qconf -#{mode}p #{config_file}"
    execute _command do
      command _command
      # wait until triggerd further down
      action :nothing
    end
    # read the default configuration for parallel environments part of this recipe
    config = Gengine::Config::parse node.gengine.defaults.parallel_environment
    # merge configuration from the repository (overwrites defaults)
    config.merge!(Gengine::Config::read("#{node.gengine.repo.path}/parallel_environments/#{name}"))
    # merge configuration from attributes (overwrites repository configuration)
    config.merge!(attribtues) unless attribtues.empty?
    # set the parallel environment name
    config['pe_name'] = name
    # write the configuration file
    file config_file do
      content Gengine::Config::create(config)
      # trigger re-cofniguration if needed
      notifies :run, "execute[#{_command}]", :immediately
    end
    # remove parallel environment from list 
    parallel_environments.delete(name)
  end
  # delete parallel environments not longer configured 
  parallel_environments.each do |name|
    `qconf -dp #{name} > /dev/null 2> /dev/null`
    Chef::Log.info("[gengine] Parallel environments '#{name}' removed from configuration")
  end
end
