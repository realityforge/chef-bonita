#
# Cookbook Name:: bonita
# Recipe:: default
#
# Copyright 2011, Fire Information Systems Group
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

base_filename = File.basename(node["bonita"]["package_url"])

cached_filename = "#{Chef::Config[:file_cache_path]}/#{base_filename}"

# Download the Bonita archive from a remote location
remote_file cached_filename do
  source node["bonita"]["package_url"]
  checksum node["bonita"]["package_checksum"]
  mode "0644"
  not_if { ::File.exists?(cached_filename) }
end

bash "unpack_bonita" do
    code <<-EOF
rm -rf /usr/local/bonita
mkdir -p /usr/local/bonita
cd /usr/local/bonita
unzip -qq #{cached_filename}
EOF
end