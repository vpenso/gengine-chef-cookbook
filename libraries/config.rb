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

module Gengine
  
  module Config

    def self.list(command)
      output = `#{command} 2> /dev/null`
      return output.empty? ? Array.new : output.split
    end

    def self.parse(string)
      config = Hash.new
      string.each_line do |line|
        key,*value = line.split
        value = value.join(' ')
        config[key] = value
      end
      return config
    end

    def self.read(file)
      Chef::Log.debug("[gengine] Reading Configuration file #{file}")
      self.parse(File.read(file))
    rescue
      Hash.new
    end

    def self.create(hash)
      config = String.new
      hash.each_pair do |key,value|
        config << "#{key} #{value}\n"
      end
      return config
    end

  end

end
