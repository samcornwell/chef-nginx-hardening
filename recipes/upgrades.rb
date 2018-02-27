# # encoding: utf-8
# #
# # Cookbook Name:: nginx-hardening
# # Recipe:: default.rb
# #
# # Copyright 2015, Edmund Haselwanter
# # Copyright 2015, Deutsche Telekom AG
# #
# # Licensed under the Apache License, Version 2.0 (the "License");
# # you may not use this file except in compliance with the License.
# # You may obtain a copy of the License at
# #
# #     http://www.apache.org/licenses/LICENSE-2.0
# #
# # Unless required by applicable law or agreed to in writing, software
# # distributed under the License is distributed on an "AS IS" BASIS,
# # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# # See the License for the specific language governing permissions and
# # limitations under the License.
# #

# # nginx requires up to date openssl packages
include_recipe 'openssl::upgrade'

# OS-specific configuration
if platform_family?('debian')
  execute 'linux_patches' do
    command 'apt-get dist-upgrade -y'
  end
end

if platform_family?('rhel', 'fedora', 'amazon')
  execute 'linux_patches' do
    command 'yum update -y'
  end
end

node['include_packages'].each do |package|
  package package do
    action :install
  end
end

node['remove_packages'].each do |package|
  package package do
    action :purge
  end
end


