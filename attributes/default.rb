#
# Cookbook Name:: bonita
# Attributes:: default
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

include_attribute "tomcat::default"

version = '5.6.2'
home_dir = "/usr/local/bonita-#{version}"
override['bonita']['version'] = version
override['bonita']['home_dir'] = home_dir
default['bonita']['package_url'] = nil
default['bonita']['license_url'] = nil

default['bonita']['database']['hibernate']['dialect'] = 'org.hibernate.dialect.SQLServerDialect'
default['bonita']['database']['exo_jcr']['dialect'] = 'mssql'
default['bonita']['database']['hibernate']['interceptor'] = 'org.ow2.bonita.env.interceptor.MSSQLServerDescNullsFirstInterceptor'
default['bonita']['database']['jdbc']['driver'] = 'net.sourceforge.jtds.jdbc.Driver'
default['bonita']['database']['jdbc']['bonita_history_url'] = nil
default['bonita']['database']['jdbc']['bonita_journal_url'] = nil
default['bonita']['database']['jdbc']['xcmis_url'] = nil
default['bonita']['database']['jdbc']['username'] = nil
default['bonita']['database']['jdbc']['password'] = nil
default['bonita']['database']['driver_package_url'] = nil

default['bonita']['xcmis']['username'] = nil
default['bonita']['xcmis']['password'] = nil

override['tomcat']['common_loader_additions'] =["#{home_dir}/lib/bonita/*.jar"]

java_options = ""
java_options += " -DBONITA_HOME=#{home_dir}/bonita"
java_options += " -Djava.security.auth.login.config=#{home_dir}/external/security/jaas-tomcat.cfg"
java_options += " -Djava.util.logging.config.file=#{home_dir}/external/logging/logging.properties"
java_options += " -Dexo.data.dir=#{home_dir}/external/xcmis/ext-exo-data"
java_options += " -Dfile.encoding=UTF-8 -Xshare:auto -Xms512m -Xmx1024m -XX:MaxPermSize=256m -XX:+HeapDumpOnOutOfMemoryError"
java_options += " -Dorg.exoplatform.container.standalone.config=#{home_dir}/external/xcmis/ext-exo-conf/exo-configuration.xml"
java_options += " -Djava.awt.headless=true"
override['tomcat']['java_options'] = java_options
