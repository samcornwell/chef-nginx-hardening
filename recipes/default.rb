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
node.default['nginx-hardening']['options']['ssl_certificate'] = ::File.join((node['nginx-hardening']['certificates_dir'] || '/etc/nginx/'), 'nginx-selfsigned.pem')
node.default['nginx-hardening']['options']['ssl_certificate_key'] = ::File.join((node['nginx-hardening']['certificates_dir'] || '/etc/nginx/'), 'nginx-selfsigned.key')
node.default['nginx-hardening']['options']['ssl_client_certificate'] = ::File.join((node['nginx-hardening']['certificates_dir'] || '/etc/nginx/'), 'dod-root-certs.pem')
node.default['nginx-hardening']['options']['ssl_crl'] = ::File.join((node['nginx-hardening']['certificates_dir'] || '/etc/nginx/'), 'DOD_CRL-bundle.crl')


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

if platform_family?('rhel', 'fedora', 'amazon')
  unless node['nginx']['repo_source'].nil?
    # repo and source installations have no extra modules
    # on RHEL/CentOS/Fedora so the affected options must be removed
    options.delete('more_clear_headers')
  end
end


file '/etc/nginx/conf.d/default.conf' do
  action :delete
  notifies :restart, 'service[nginx]', :immediately
end

file '/usr/share/man/man8/nginx.8.gz' do
  action :delete
end

openssl_dhparam node['nginx-hardening']['options']['ssl_dhparam'] do
  key_length node['nginx-hardening']['dh-size']
  not_if { File.exist?(node['nginx-hardening']['options']['ssl_dhparam']) }
end

openssl_x509 'generate_self_signed_certs' do
  path node['nginx-hardening']['options']['ssl_certificate']
  common_name node['ipaddress']
  org 'DISA ou=PKI ou=DoD'
  org_unit 'U.S. Government'
  country 'US'
  not_if { File.exist?(node['nginx-hardening']['options']['ssl_certificate']) and File.exist?(node['nginx-hardening']['options']['ssl_certificate_key']) }
end

node['cert_files'].each do |cert|
  cookbook_file cert do
    path ::File.join((node['nginx-hardening']['certificates_dir'] || '/etc/nginx/'), cert)
    source cert
    owner node['system_admin']
    group node['system_admin']
    mode '0660'
    action :create
  end
end


package "unzip" 
package "wget" 

bash 'update/install DOD CRL bundle' do
  cwd ::File.join((node['nginx-hardening']['certificates_dir'] || '/etc/nginx/'))
  code <<-EOH
      rm DOD_CRL-bundle.crl # Remove any pre-existing one.
      rm -rf crl_temp; mkdir crl_temp; cd crl_temp # Create temp dir to make bundle
      wget "https://crl.disa.mil/getcrlzip?ALL+CRL+ZIP" --no-check-certificate -O ALLCRLZIP.zip
      unzip ALLCRLZIP.zip
      for f in *.crl ; do  # Convert to PEM format.
        openssl crl -inform DER -outform PEM -in "$f" -out "${f%.crl}.pem_crl"
      done
      cat *.pem_crl > DOD_CRL-bundle.crl
      mv DOD_CRL-bundle.crl ../ 
      cd ../; rm -rf crl_temp # Remove temp dir to make bundle
    EOH
  # Run if CRL was updated more than specified days ago
  not_if { File.exist?(node['nginx-hardening']['options']['ssl_crl']) and File.ctime(node['nginx-hardening']['options']['ssl_crl']) >  Time.now - node['nginx-hardening']['crl_udpate_frequency_days'] * 86400 }
end

file File.join((node['nginx-hardening']['certificates_dir'] || '/etc/nginx/'), 'DOD_CRL-bundle.crl') do
  owner node['system_admin']
  group node['system_admin']
  mode '0660'
end

template "#{node['nginx']['dir']}/conf.d/90.hardening.conf" do
  source 'extras.conf.erb'
  variables(
    options: NginxHardening.options(options)
  )
  notifies :restart, 'service[nginx]', :immediately
end

template "#{node['nginx']['dir']}/sites-enabled/vserver.conf" do
  source 'server.erb'
  variables(
    listen: [ "#{node['ipaddress']}:443 ssl", "#{node['ipaddress']}:80" ],
    docroot: '/var/www/vserver/html/'
  )
  owner node['nginx_owner']
  group node['nginx_owner']
  mode '0660'
end

#@TODO each the dirs on the path to the web app must have the following permissions
# need a way to do this better
['/var/www/','/var/www/vserver/','/var/www/vserver/html/'].each do |folder|
  directory folder do
    owner node['nginx_owner']
    group node['nginx_owner']
    mode '1755'
    action :create
  end
end

cookbook_file '/var/www/vserver/html/index.html' do
  source 'index.html'
  owner node['nginx_owner']
  group node['nginx_owner']
  mode '1755'
  action :create
end


