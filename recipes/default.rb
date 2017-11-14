# encoding: utf-8
#
# Cookbook Name:: nginx-hardening
# Recipe:: default.rb
#
# Copyright 2014, Dominik Richter
# Copyright 2014, Deutsche Telekom AG
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

include_recipe('nginx-hardening::minimize_access')

node.default['nginx-hardening']['options']['ssl_dhparam'] = ::File.join((node['nginx-hardening']['certificates_dir'] || '/etc/nginx/'), 'dh2048.pem')
options = node['nginx-hardening']['options'].to_hash

# OS-specific configuration
if platform_family?('debian')

  # when installing from canonical package on Ubuntu
  # we can get additional modules via extra package
  if node['nginx']['install_method'] == 'package' && node['nginx']['repo_source'].nil?
    package 'nginx-extras'
  else
    # repo and source installations have no extra modules
    # on ubuntu/debian so the affected options must be removed
    options.delete('more_clear_headers')
  end

end

if platform_family?('rhel', 'fedora')
  unless node['nginx']['repo_source'].nil?
    # repo and source installations have no extra modules
    # on RHEL/CentOS/Fedora so the affected options must be removed
    options.delete('more_clear_headers')
  end
end

template "#{node['nginx']['dir']}/conf.d/90.hardening.conf" do
  source 'extras.conf.erb'
  variables(
    options: NginxHardening.options(options)
  )
  notifies :restart, 'service[nginx]', :immediately
end

file '/etc/nginx/conf.d/default.conf' do
  action :delete
  notifies :restart, 'service[nginx]', :immediately
end

file '/usr/share/man/man8/nginx.8.gz' do
  action :delete
end

execute 'generate_dh_group' do
  command "openssl dhparam -out #{node['nginx-hardening']['options']['ssl_dhparam']} #{node['nginx-hardening']['dh-size']}"
  not_if { File.exist?(node['nginx-hardening']['options']['ssl_dhparam']) }
end

directory '/usr/sbin/nginx' do
  owner node['system_admin']
  group node['system_admin']
  mode '550'
end

directory '/etc/nginx/' do
  owner node['system_admin']
  group node['system_admin']
  mode '770'
end

directory '/etc/nginx/conf.d' do
  owner node['system_admin']
  group node['system_admin']
  mode '770'
end

directory '/etc/nginx/modules' do
  owner node['system_admin']
  group node['system_admin']
  mode '770'
end
directory '/usr/share/nginx/html' do
  owner node['nginx_owner']
  group node['nginx_owner']
  mode '664'
end
directory '/var/log/nginx' do
  owner  node['system_admin']
  group  node['system_admin']
  mode '750'
end

directory '/var/local' do
  owner  node['nginx_owner']
  group  node['nginx_owner']
  mode '1660'
end

node['cert_files'].each do |cert|
  cookbook_file cert do
    source File.basename(cert)
    owner node['system_admin']
    group node['system_admin']
    mode '0660'
    action :create
  end
end

node['virtual_servers'].each do |server|
  cookbook_file server do
    source File.basename(server)
    owner node['nginx_owner']
    group node['nginx_owner']
    mode '0660'
    action :create
  end
end

node['nginx_files'].each do |nginx_file|
  file nginx_file do
    owner  node['nginx_owner']
    group  node['nginx_owner']
    mode '0660'
  end
end


node['root_folders'].each do |folder|
  directory folder do
    owner node['nginx_owner']
    group node['nginx_owner']
    mode '1660'
    action :create
  end
end
