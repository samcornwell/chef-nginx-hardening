# encoding: utf-8
#
# Cookbook Name:: nginx-hardening
# Recipe:: default.rb
#
# Copyright 2015, Edmund Haselwanter
# Copyright 2015, Deutsche Telekom AG
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

# nginx requires up to date openssl packages
include_recipe 'openssl::upgrade'

package 'nss-sysinit' do
 action :upgrade
end

package 'chkconfig' do
 action :upgrade
end

package 'dracut' do
 action :upgrade
end

package 'device-mapper-libs' do
 action :upgrade
end

package 'kpartx' do
 action :upgrade
end

package 'gawk' do
 action :upgrade
end

package 'bind-license' do
 action :upgrade
end
package 'ca-certificates' do
 action :upgrade
end
package 'device-mapper' do
 action :upgrade
end

package 'glibc' do
  action :upgrade
end

package 'glibc-common' do
  action :upgrade
end

package 'audit' do
  version '2.6.5-3.el7_3.1'
  action :install
end
