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

default["bonita"]["version"] = '5.6'
default["bonita"]["package_url"] = "#{node["maven"]["repository_url"]}/com/bonitasoft/bonitasoft-server/#{default["bonita"]["version"]}/bonitasoft-server-#{default["bonita"]["version"]}.zip"
default["bonita"]["package_checksum"] = "e8570411241c0fdaef2f886f64bb10be8f659db3"