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

default['bonita']['home_dir'] = '/usr/local/bonita'

default['bonita']['user'] = nil
default['bonita']['group'] = nil

default['bonita']['license']['url'] = nil
default['bonita']['license']['type'] = 'development'
default['bonita']['license']['request'] = nil

default['bonita']['packages']['bonita_url'] = nil
default['bonita']['packages']['client_url'] = nil
default['bonita']['packages']['keygen_url'] = nil

default['bonita']['database']['hibernate']['dialect'] = 'org.hibernate.dialect.SQLServerDialect'
default['bonita']['database']['hibernate']['interceptor'] = 'org.ow2.bonita.env.interceptor.MSSQLServerDescNullsFirstInterceptor'
default['bonita']['database']['jdbc']['driver'] = 'net.sourceforge.jtds.jdbc.Driver'
default['bonita']['database']['jdbc']['history']['resource'] = nil
default['bonita']['database']['jdbc']['history']['url'] = nil
default['bonita']['database']['jdbc']['history']['search_index_dir'] = '/usr/local/bonita/bonita/server/default/work/indexes/history'
default['bonita']['database']['jdbc']['history']['schema'] = nil
default['bonita']['database']['jdbc']['journal']['resource'] = nil
default['bonita']['database']['jdbc']['journal']['url'] = nil
default['bonita']['database']['jdbc']['journal']['search_index_dir'] = '/usr/local/bonita/bonita/server/default/work/indexes/journal'
default['bonita']['database']['jdbc']['journal']['schema'] = nil
default['bonita']['database']['jdbc']['username'] = nil
default['bonita']['database']['jdbc']['password'] = nil

default['bonita']['large_data_repository'] = '/usr/local/bonita/bonita/server/default/work'

default['bonita']['tomcat']['extra_libraries'] = []
default['bonita']['tomcat']['logging_properties'] = Mash.new
