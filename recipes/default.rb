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

raise "node['bonita']['database']['jdbc']['username'] not set" unless node['bonita']['database']['jdbc']['username']
raise "node['bonita']['database']['jdbc']['password'] not set" unless node['bonita']['database']['jdbc']['password']
raise "node['bonita']['xcmis']['username'] not set" unless node['bonita']['xcmis']['username']
raise "node['bonita']['xcmis']['password'] not set" unless node['bonita']['xcmis']['password']

package_url = node["bonita"]["package_url"]
base_package_filename = File.basename(package_url)
cached_package_filename = "#{Chef::Config[:file_cache_path]}/#{base_package_filename}"

driver_url = node["bonita"]["database"]["driver_package_url"]
driver_base_filename = File.basename(driver_url)
cached_driver_filename = "#{Chef::Config[:file_cache_path]}/#{driver_base_filename}"

# Download the Bonita archive from a remote location
remote_file cached_package_filename do
  source package_url
  mode "0600"
  not_if { ::File.exists?(cached_package_filename) }
end

remote_file cached_driver_filename do
  source driver_url
  mode "0600"
  not_if { ::File.exists?(cached_driver_filename) }
end

bash "unpack_and_setup_bonita" do
    code <<-EOF
mkdir /tmp/bonita
cd /tmp/bonita
unzip -qq #{cached_package_filename}
cd BOS-SP-#{node["bonita"]["version"]}-Tomcat-6.0.33
cp #{cached_driver_filename} lib/bonita
rm -rf bin conf lib/*.jar logs temp work webapps/docs webapps/examples webapps/host-manager webapps/manager
mkdir -p bonita/server/licenses
mkdir -p bonita/server/default/conf
mkdir -p external/logging
mkdir -p external/xcmis/ext-exo-conf
chown -R #{node["tomcat"]["user"]} .
chgrp -R #{node["tomcat"]["group"]} .
find . -type f -exec chmod 0600 {} \\;
cd /tmp/bonita
rm -rf #{node["bonita"]["home_dir"]}
mv BOS-SP-#{node["bonita"]["version"]}-Tomcat-6.0.33 #{node["bonita"]["home_dir"]}
rm -rf /tmp/bonita
EOF
  not_if { ::File.exists?(node["bonita"]["home_dir"]) }
end

if node["bonita"]["license_url"]
  remote_file "#{node["bonita"]["home_dir"]}/bonita/server/licenses/license.lic" do
    source node["bonita"]["license_url"]
    owner node["tomcat"]["user"]
    group node["tomcat"]["group"]
    mode "0600"
  end
end

template "#{node["bonita"]["home_dir"]}/bonita/server/default/conf/bonita-history.properties" do
  source "bonita-history.properties.erb"
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  mode "0600"
  notifies :restart, "service[tomcat]", :delayed
end

template "#{node["bonita"]["home_dir"]}/external/logging/logging.properties" do
  source "logging.properties.erb"
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  mode "0600"
  notifies :restart, "service[tomcat]", :delayed
end

template "#{node["bonita"]["home_dir"]}/bonita/server/default/conf/bonita-journal.properties" do
  source "bonita-journal.properties.erb"
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  mode "0600"
  notifies :restart, "service[tomcat]", :delayed
end

template "#{node["bonita"]["home_dir"]}/external/xcmis/ext-exo-conf/exo-configuration.xml" do
  source "exo-configuration.xml.erb"
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  mode "0600"
  notifies :restart, "service[tomcat]", :delayed
end

template "#{node["bonita"]["home_dir"]}/external/xcmis/ext-exo-conf/cmis-jcr-configuration.xml" do
  source "cmis-jcr-configuration.xml.erb"
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  mode "0600"
  notifies :restart, "service[tomcat]", :delayed
end

template "#{node["bonita"]["home_dir"]}/bonita/server/default/conf/bonita-server.xml" do
  source "bonita-server.xml.erb"
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  mode "0600"
  notifies :restart, "service[tomcat]", :delayed
end

template "#{node['tomcat']['context_dir']}/bonita.xml" do
  source "bonita-context.xml.erb"
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  mode "0600"
  variables(:war => "#{node["bonita"]["home_dir"]}/webapps/bonita.war")
  notifies :restart, "service[tomcat]", :delayed
end

template "#{node['tomcat']['context_dir']}/xcmis.xml" do
  source "xcmis-context.xml.erb"
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  mode "0600"
  variables(:war => "#{node["bonita"]["home_dir"]}/webapps/xcmis.war")
  notifies :restart, "service[tomcat]", :delayed
end

template "#{node['tomcat']['context_dir']}/bonita-app.xml" do
  source "base-context.xml.erb"
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  mode "0600"
  variables(:war => "#{node["bonita"]["home_dir"]}/webapps/bonita-app.war", :path => '/bonita-app')
  notifies :restart, "service[tomcat]", :delayed
end
