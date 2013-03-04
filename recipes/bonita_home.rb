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

raise "node['bonita']['packages']['client_url'] not set" unless node['bonita']['packages']['client_url']
raise "node['bonita']['packages']['keygen_url'] not set" unless node['bonita']['packages']['keygen_url']

["",
 "/bonita",
 "/bonita/client",
 "/bonita/server",
 "/bonita/server/licenses",
 "/bonita/server/default",
 "/bonita/server/default/conf",
].each do |directory|
  directory "#{node['bonita']['home_dir']}#{directory}" do
    owner node['bonita']['user']
    group node['bonita']['group']
    mode '0700'
    recursive true
  end
end

require 'digest/sha1'

client_filename = "#{node['bonita']['home_dir']}/bpm-client-#{Digest::SHA1.hexdigest(node['bonita']['packages']['client_url'])}.zip"
remote_file client_filename do
  source node['bonita']['packages']['client_url']
  mode '0600'
  owner node['bonita']['user']
  group node['bonita']['group']
  action :create_if_missing
end

keygen_filename = "#{node['bonita']['home_dir']}/bpm-keygen-#{Digest::SHA1.hexdigest(node['bonita']['packages']['keygen_url'])}.jar"
remote_file keygen_filename do
  source node['bonita']['packages']['keygen_url']
  mode '0600'
  owner node['bonita']['user']
  group node['bonita']['group']
  action :create_if_missing
end

package 'zip'

execute "unzip client libs" do
  command "unzip -u -o #{client_filename}"
  user node['bonita']['user']
  group node['bonita']['group']
  umask '0600'
  cwd "#{node['bonita']['home_dir']}/bonita/client"
  action :run
  not_if { ::File.exist?("#{node['bonita']['home_dir']}/bonita/client/tenants/default/web/XP/looknfeel/default/BonitaConsole.html") }
end

ruby_block "generate_license_request" do
  block do
    dev_mode = node['bonita']['license']['type'] != 'production'
    node.override['bonita']['license']['request'] =
      `echo #{node['cpu']['total']} | java -cp #{keygen_filename} org.bonitasoft.security.generateKey.GenerateKey#{dev_mode ? 'Dev' : ''} | tail -n 1`
  end
end

if node['bonita']['license']['url']
  remote_file "#{node['bonita']['home_dir']}/bonita/server/licenses/license.lic" do
    source node['bonita']['license']['url']
    owner node['bonita']['user']
    group node['bonita']['group']
    mode '0600'
  end
end

template "#{node['bonita']['home_dir']}/bonita/server/default/conf/bonita-history.properties" do
  source 'bonita-history.properties.erb'
  owner node['bonita']['user']
  group node['bonita']['group']
  mode '0600'
end

template "#{node['bonita']['home_dir']}/bonita/server/default/conf/bonita-journal.properties" do
  source 'bonita-journal.properties.erb'
  owner node['bonita']['user']
  group node['bonita']['group']
  mode '0600'
end

template "#{node['bonita']['home_dir']}/bonita/server/default/conf/bonita-server.xml" do
  source 'bonita-server.xml.erb'
  owner node['bonita']['user']
  group node['bonita']['group']
  mode '0600'
end
