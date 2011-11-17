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

package_url = node["bonita"]["package_url"]
base_package_filename = File.basename(package_url)
cached_package_filename = "#{Chef::Config[:file_cache_path]}/#{base_package_filename}"

driver_url = node["bonita"]["database"]["driver_package_url"]
driver_base_filename = File.basename(driver_url)
cached_driver_filename = "#{Chef::Config[:file_cache_path]}/#{driver_base_filename}"

# Download the Bonita archive from a remote location
remote_file cached_package_filename do
  source package_url
  checksum node["bonita"]["package_checksum"]
  mode "0600"
  not_if { ::File.exists?(cached_package_filename) }
end

remote_file cached_driver_filename do
  source driver_url
  checksum node["bonita"]["database"]["driver_package_checksum"]
  mode "0600"
  not_if { ::File.exists?(cached_driver_filename) }
end

bash "unpack_bonita" do
    code <<-EOF
rm -rf /usr/local/bonita
mkdir -p /usr/local/bonita
cd /usr/local/bonita
unzip -qq #{cached_package_filename}
cp #{cached_driver_filename} /usr/local/bonita/bonita_execution_engine/engine/libs/#{driver_base_filename}
EOF
end

directory "/usr/local/bonita/conf/bonita/licenses" do
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  mode "0700"
end

template "/usr/local/bonita/conf/bonita/server/default/conf/bonita-history.properties" do
  source "bonita-history.properties.erb"
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  mode "0700"
  notifies :restart, resources(:service => "tomcat")
end

template "/usr/local/bonita/conf/bonita/server/default/conf/bonita-journal.properties" do
  source "bonita-journal.properties.erb"
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  mode "0700"
  notifies :restart, resources(:service => "tomcat")
end

template "/usr/local/bonita/conf/external/xcmis/ext-exo-conf/exo-configuration.xml" do
  source "exo-configuration.xml.erb"
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  mode "0700"
  notifies :restart, resources(:service => "tomcat")
end

template "/usr/local/bonita/conf/external/xcmis/ext-exo-conf/cmis-jcr-configuration.xml" do
  source "cmis-jcr-configuration.xml.erb"
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  mode "0700"
  notifies :restart, resources(:service => "tomcat")
end

template "#{node['tomcat']['webapp_dir']}/bonita.xml" do
  source "bonita_context.xml.erb"
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  mode "0700"
  variables(:war => "/usr/local/bonita/bonita_user_experience/without_execution_engine_without_client/bonita.war")
  notifies :restart, resources(:service => "tomcat")
end

template "#{node['tomcat']['webapp_dir']}/xcmis.xml" do
  source "xcmis_context.xml.erb"
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  mode "0700"
  variables(:war => "/usr/local/bonita/xcmis/xcmis.war")
  notifies :restart, resources(:service => "tomcat")
end