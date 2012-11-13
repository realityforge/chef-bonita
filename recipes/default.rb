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

include_recipe "tomcat::default"

raise "node['bonita']['database']['jdbc']['username'] not set" unless node['bonita']['database']['jdbc']['username']
raise "node['bonita']['database']['jdbc']['password'] not set" unless node['bonita']['database']['jdbc']['password']
raise "node['bonita']['xcmis']['username'] not set" unless node['bonita']['xcmis']['username']
raise "node['bonita']['xcmis']['password'] not set" unless node['bonita']['xcmis']['password']

raise "node['bonita']['package_url'] not set" unless node['bonita']['package_url']

package_url = node['bonita']['package_url']
base_package_filename = File.basename(package_url)
cached_package_filename = "#{Chef::Config[:file_cache_path]}/#{base_package_filename}"

# Download the Bonita archive from a remote location
remote_file cached_package_filename do
  source package_url
  mode '0600'
  action :create_if_missing
end

bash "unpack_and_setup_bonita" do
    code <<-EOF
mkdir /tmp/bonita
cd /tmp/bonita
unzip -qq #{cached_package_filename}
cd BOS-SP-#{node['bonita']['version']}-Tomcat-6.0.33
rm -rf bin conf lib/*.jar logs temp work webapps/docs webapps/examples webapps/host-manager webapps/manager webapps/ROOT bonita/client NOTICE LICENSE RELEASE-NOTES RUNNING.txt
mkdir -p bonita/server/licenses
mkdir -p bonita/server/default/conf
mkdir -p external/logging
mkdir -p external/xcmis/ext-exo-conf
chown -R #{node['tomcat']['user']} .
chgrp -R #{node['tomcat']['group']} .
find . -type f -exec chmod 0600 {} \\;
cd /tmp/bonita
rm -rf #{node['bonita']['home_dir']}
mv BOS-SP-#{node['bonita']['version']}-Tomcat-6.0.33 #{node['bonita']['home_dir']}
rm -rf /tmp/bonita
EOF
  not_if { ::File.exists?(node['bonita']['home_dir']) }
end

node['bonita']['extra_libraries'].each do |library|
  filename = "#{node['bonita']['home_dir']}/lib/bonita/#{File.basename(library)}"
  remote_file filename do
    source library
    owner node['tomcat']['user']
    group node['tomcat']['group']
    mode '0600'
    action :create_if_missing
    notifies :restart, 'service[tomcat]', :delayed
  end
end

if node['bonita']['license_url']
  remote_file "#{node['bonita']['home_dir']}/bonita/server/licenses/license.lic" do
    source node['bonita']['license_url']
    owner node['tomcat']['user']
    group node['tomcat']['group']
    mode '0600'
  end
end

template "#{node['bonita']['home_dir']}/bonita/server/default/conf/bonita-history.properties" do
  source 'bonita-history.properties.erb'
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode '0600'
  notifies :restart, 'service[tomcat]', :delayed
end

logging_properties = {
  "handlers" => "java.util.logging.FileHandler",
  ".level" => "INFO",
  "java.util.logging.FileHandler.pattern" => "#{node['tomcat']['log_dir']}/bonita%u.log",
  "java.util.logging.FileHandler.limit" => "50000",
  "java.util.logging.FileHandler.count" => "1",
  "java.util.logging.FileHandler.formatter" => "java.util.logging.SimpleFormatter",
  "org.ow2.bonita.level" => "INFO",
  "org.ow2.bonita.example.level" => "FINE",
  "org.ow2.bonita.runtime.event.EventDispatcherThread.level" => "WARNING",
  "org.bonitasoft.level" => "INFO",
  "org.hibernate.level" => "WARNING",
  "net.sf.ehcache.level" => "SEVERE",
  "org.apache.catalina.session.PersistentManagerBase.level" => "OFF"
}

logging_properties.merge!(node['bonita']['logging_properties'].to_hash)

template "#{node['bonita']['home_dir']}/external/logging/logging.properties" do
  source 'logging.properties.erb'
  cookbook 'bonita'
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode '0600'
  variables(:logging_properties => logging_properties)
  notifies :restart, 'service[tomcat]', :delayed
end

template "#{node['bonita']['home_dir']}/bonita/server/default/conf/bonita-journal.properties" do
  source 'bonita-journal.properties.erb'
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode '0600'
  notifies :restart, 'service[tomcat]', :delayed
end

template "#{node['bonita']['home_dir']}/external/xcmis/ext-exo-conf/exo-configuration.xml" do
  source 'exo-configuration.xml.erb'
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode '0600'
  notifies :restart, 'service[tomcat]', :delayed
end

template "#{node['bonita']['home_dir']}/external/xcmis/ext-exo-conf/cmis-jcr-configuration.xml" do
  source 'cmis-jcr-configuration.xml.erb'
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode '0600'
  notifies :restart, 'service[tomcat]', :delayed
end

["cmis-nodetypes-config.xml", "nodetypes-config-extended.xml", "nodetypes-config.xml", "organization-nodetypes.xml"].
  each do |config_filename|
  cookbook_file "#{node['bonita']['home_dir']}/external/xcmis/ext-exo-conf/#{config_filename}" do
    source "xcmis/#{config_filename}"
    owner node['tomcat']['user']
    group node['tomcat']['group']
    mode '0600'
    notifies :restart, 'service[tomcat]', :delayed
  end
end

cookbook_file "#{node['bonita']['home_dir']}/external/security/jaas-tomcat.cfg" do
  source "jaas-tomcat.cfg"
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode '0600'
  notifies :restart, 'service[tomcat]', :delayed
end

template "#{node['bonita']['home_dir']}/bonita/server/default/conf/bonita-server.xml" do
  source 'bonita-server.xml.erb'
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode '0600'
  notifies :restart, 'service[tomcat]', :delayed
end

template "#{node['tomcat']['context_dir']}/bonita.xml" do
  source 'bonita-context.xml.erb'
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode '0600'
  variables(:war => "#{node['bonita']['home_dir']}/webapps/bonita.war")
  notifies :restart, 'service[tomcat]', :delayed
end

template "#{node['tomcat']['context_dir']}/xcmis.xml" do
  source 'xcmis-context.xml.erb'
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode '0600'
  variables(:war => "#{node['bonita']['home_dir']}/webapps/xcmis.war")
  notifies :restart, 'service[tomcat]', :delayed
end

template "#{node['tomcat']['context_dir']}/bonita-app.xml" do
  source 'base-context.xml.erb'
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode '0600'
  variables(:war => "#{node['bonita']['home_dir']}/webapps/bonita-app.war", :path => '/bonita-app')
  notifies :restart, 'service[tomcat]', :delayed
end
