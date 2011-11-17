#
# Cookbook Name:: bonita
# Attributes:: default
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

default["bonita"]["package_url"] = nil
default["bonita"]["package_checksum"] = nil

default["bonita"]["database"]["hibernate"]["dialect"] = "org.hibernate.dialect.SQLServerDialect"
default["bonita"]["database"]["exo_jcr"]["dialect"] = "mssql"
default["bonita"]["database"]["hibernate"]["interceptor"] = "org.ow2.bonita.env.interceptor.MSSQLServerDescNullsFirstInterceptor"
default["bonita"]["database"]["jdbc"]["driver"] = "net.sourceforge.jtds.jdbc.Driver"
default["bonita"]["database"]["jdbc"]["bonita_url"] = nil
default["bonita"]["database"]["jdbc"]["xcmis_url"] = nil
default["bonita"]["database"]["jdbc"]["username"] = "bonita"
default["bonita"]["database"]["jdbc"]["password"] = "bonita"
default["bonita"]["database"]["driver_package_url"] = nil
default["bonita"]["database"]["driver_package_checksum"] = nil

unless node["tomcat"]["common_loader_additions"].any? { |entry| entry =~ /bonita_execution_engine/ }
  set["tomcat"]["common_loader_additions"] =
    node["tomcat"]["common_loader_additions"] +
      ['/usr/local/bonita/bonita_execution_engine/engine/libs/*.jar', '/usr/local/bonita/bonita_execution_engine/bonita_client/libs/*.jar']
end

unless node["tomcat"]["java_options"] =~ /org\.exoplatform\.container\.standalone\.config/
  java_options = node["tomcat"]["java_options"]
  java_options += " -DBONITA_HOME=/usr/local/bonita/conf/bonita"
  java_options += " -Djava.security.auth.login.config=/usr/local/bonita/conf/external/security/jaas-standard.cfg"
  java_options += " -Dexo.data.dir=/usr/local/bonita/conf/external/xcmis/ext-exo-data"
  java_options += " -Dorg.exoplatform.container.standalone.config=/usr/local/bonita/conf/external/xcmis/ext-exo-conf/exo-configuration.xml"
  default["tomcat"]["java_options"] = java_options
end