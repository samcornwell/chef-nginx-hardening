# encoding: utf-8
#
# Cookbook Name:: nginx-hardening
# Attributes:: default
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

include_attribute 'nginx'

# to be on par with the puppet module defaults

default['system_admin'] = 'root'
default['nginx_owner'] = 'nginx'

#V-13727
default['nginx']['worker_processes'] = 'auto'

#V-13726
default['nginx']['keepalive_timeout'] = '5 5'

#V-13726
default['nginx']['keepalive_timeout'] = '5 5'

default['nginx-hardening']['disable_symlinks'] = 'on'
default['nginx-hardening']['autoindex'] = 'off'

if platform_family?('debian')
    default['include_packages'] = ['auditd']
end
if platform_family?('rhel', 'fedora', 'amazon')
    default['include_packages'] = ['audit']
end

default['nginx-hardening']['certificates_dir'] = '/etc/ssl/certs/'

default['remove_packages'] = ['postfix']

default['cert_files'] = ['dod-root-certs.pem']

default['nginx_files'] = ['/etc/nginx/nginx.conf',
                         '/etc/nginx/mime.types',
                         '/etc/nginx/conf.d/90.hardening.conf',
                         '/var/run/nginx.pid']

