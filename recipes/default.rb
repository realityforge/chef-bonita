#
# Cookbook Name:: bonita
# Recipe:: default
#
# Copyright 2011, Peter Donald
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
mkdir /tmp/bonita
cd /tmp/bonita
unzip -qq #{cached_package_filename}
cd BOS-SP-5.6-Tomcat-6.0.33
rm -rf bin conf lib/*.jar logs temp work webapps/docs webapps/examples webapps/host-manager webapps/manager
cd /tmp/bonita
rm -rf /usr/local/bonita-5.6
mv BOS-SP-5.6-Tomcat-6.0.33 /usr/local/bonita-5.6
rm -rf /tmp/bonita
EOF
  not_if { ::File.exists?('/usr/local/bonita-5.6') }
end

remote_file "/usr/local/bonita-5.6/bonita/server/licenses/license.lic" do
  source node["bonita"]["license_url"]
  checksum node["bonita"]["license_checksum"]
  mode "0600"
end

bash "add_database_driver_to_bonita" do
    code <<-EOF
cp #{cached_driver_filename} /usr/local/bonita-5.6/lib/bonita/
EOF
  not_if { ::File.exists?("/usr/local/bonita-5.6/lib/bonita/#{driver_base_filename}") }
end

bash "config_permissions" do
    code <<-EOF
chown -R #{node["tomcat"]["user"]} /usr/local/bonita-5.6
chgrp -R #{node["tomcat"]["group"]} /usr/local/bonita-5.6
find /usr/local/bonita-5.6 -type f -exec chmod 0700 {} \\;
EOF
end

template "/usr/local/bonita-5.6/bonita/server/default/conf/bonita-history.properties" do
  source "bonita-history.properties.erb"
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  mode "0700"
  notifies :restart, resources(:service => "tomcat")
end

template "/usr/local/bonita-5.6/external/logging/logging.properties" do
  source "logging.properties.erb"
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  mode "0700"
  notifies :restart, resources(:service => "tomcat")
end

template "/usr/local/bonita-5.6/bonita/server/default/conf/bonita-journal.properties" do
  source "bonita-journal.properties.erb"
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  mode "0700"
  notifies :restart, resources(:service => "tomcat")
end

template "/usr/local/bonita-5.6/external/xcmis/ext-exo-conf/exo-configuration.xml" do
  source "exo-configuration.xml.erb"
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  mode "0700"
  notifies :restart, resources(:service => "tomcat")
end

template "/usr/local/bonita-5.6/external/xcmis/ext-exo-conf/cmis-jcr-configuration.xml" do
  source "cmis-jcr-configuration.xml.erb"
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  mode "0700"
  notifies :restart, resources(:service => "tomcat")
end

template "/usr/local/bonita-5.6/bonita/server/default/conf/bonita-server.xml" do
  source "bonita-server.xml.erb"
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  mode "0700"
  notifies :restart, resources(:service => "tomcat")
end

template "#{node['tomcat']['context_dir']}/bonita.xml" do
  source "bonita-context.xml.erb"
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  mode "0700"
  variables(:war => "/usr/local/bonita-5.6/webapps/bonita.war")
  notifies :restart, resources(:service => "tomcat")
end

template "#{node['tomcat']['context_dir']}/xcmis.xml" do
  source "base-context.xml.erb"
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  mode "0700"
  variables(:war => "/usr/local/bonita-5.6/webapps/xcmis.war", :path => '/xcmis')
  notifies :restart, resources(:service => "tomcat")
end

template "#{node['tomcat']['context_dir']}/bonita-app.xml" do
  source "base-context.xml.erb"
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  mode "0700"
  variables(:war => "/usr/local/bonita-5.6/webapps/bonita-app.war", :path => '/bonita-app')
  notifies :restart, resources(:service => "tomcat")
end
