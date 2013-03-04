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

node.override['tomcat']['common_loader_additions'] = ["#{node['bonita']['home_dir']}/lib/bonita/*.jar"]

java_options = ""
java_options += " -DBONITA_HOME=#{node['bonita']['home_dir']}/bonita"
java_options += " -Djava.security.auth.login.config=#{node['bonita']['home_dir']}/external/security/jaas-tomcat.cfg"
java_options += " -Djava.util.logging.config.file=#{node['bonita']['home_dir']}/external/logging/logging.properties"
java_options += " -Dfile.encoding=UTF-8 -Xshare:auto -Xms512m -Xmx2048m -XX:MaxPermSize=256m -XX:+HeapDumpOnOutOfMemoryError"
java_options += " -Djava.awt.headless=true"
node.override['tomcat']['java_options'] = java_options

include_recipe "tomcat::default"

raise "node['bonita']['database']['jdbc']['username'] not set" unless node['bonita']['database']['jdbc']['username']
raise "node['bonita']['database']['jdbc']['password'] not set" unless node['bonita']['database']['jdbc']['password']
raise "node['bonita']['packages']['bonita_url'] not set" unless node['bonita']['packages']['bonita_url']

node.override['bonita']['user'] = node['tomcat']['user']
node.override['bonita']['group'] = node['tomcat']['group']
node.override['bonita']['database']['jdbc']['history']['resource'] = 'java:/comp/env/bonita/default/history'
node.override['bonita']['database']['jdbc']['journal']['resource'] = 'java:/comp/env/bonita/default/journal'

include_recipe "bonita::bonita_home"

ruby_block "restart_tomcat" do
  block do
  end
  action :nothing
  subscribes :create, "template[#{node['bonita']['home_dir']}/bonita/server/default/conf/bonita-history.properties]", :delayed
  subscribes :create, "template[#{node['bonita']['home_dir']}/bonita/server/default/conf/bonita-journal.properties]", :delayed
  subscribes :create, "template[#{node['bonita']['home_dir']}/bonita/server/default/conf/bonita-server.xml]", :delayed
  notifies :restart, 'service[tomcat]', :delayed
end

["/external",
 "/external/logging",
 "/external/security",
 "/lib",
 "/lib/bonita",
].each do |directory|
  directory "#{node['bonita']['home_dir']}#{directory}" do
    owner node['bonita']['user']
    group node['bonita']['group']
    mode '0700'
    recursive true
  end
end

node['bonita']['tomcat']['extra_libraries'].each do |library|
  filename = "#{node['bonita']['home_dir']}/lib/bonita/#{File.basename(library)}"
  remote_file filename do
    source library
    owner node['bonita']['user']
    group node['bonita']['group']
    mode '0600'
    action :create_if_missing
    notifies :restart, 'service[tomcat]', :delayed
  end
end

require 'digest/sha1'

bonita_filename = "#{node['bonita']['home_dir']}/bpm-bonita-#{Digest::SHA1.hexdigest(node['bonita']['packages']['bonita_url'])}.war"
remote_file bonita_filename do
  source node['bonita']['packages']['bonita_url']
  mode '0600'
  owner node['bonita']['user']
  group node['bonita']['group']
  action :create_if_missing
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

logging_properties.merge!(node['bonita']['tomcat']['logging_properties'].to_hash)

template "#{node['bonita']['home_dir']}/external/logging/logging.properties" do
  source 'logging.properties.erb'
  cookbook 'bonita'
  owner node['bonita']['user']
  group node['bonita']['group']
  mode '0600'
  variables(:logging_properties => logging_properties)
  notifies :restart, 'service[tomcat]', :delayed
end

cookbook_file "#{node['bonita']['home_dir']}/external/security/jaas-tomcat.cfg" do
  source "jaas-tomcat.cfg"
  owner node['bonita']['user']
  group node['bonita']['group']
  mode '0600'
  notifies :restart, 'service[tomcat]', :delayed
end

directory "#{node["tomcat"]["webapp_dir"]}/bonita" do
  recursive true
  action :nothing
end

template "#{node['tomcat']['context_dir']}/bonita.xml" do
  source 'bonita-context.xml.erb'
  owner node['bonita']['user']
  group node['bonita']['group']
  mode '0600'
  variables(:war => bonita_filename)
  notifies :restart, 'service[tomcat]', :delayed
  notifies :delete, "directory[#{node['tomcat']['webapp_dir']}/bonita]", :immediate
end

file "#{node['tomcat']['context_dir']}/manager.xml" do
  action :delete
  notifies :restart, 'service[tomcat]', :delayed
end

file "#{node['tomcat']['context_dir']}/host-manager.xml" do
  action :delete
  notifies :restart, 'service[tomcat]', :delayed
end
