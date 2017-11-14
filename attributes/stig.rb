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

include_attribute 'chef_nginx'

# to be on par with the puppet module defaults

#V-13727
node.set['nginx']['worker_processes'] = 'auto'

#V-13726
node.set['nginx']['keepalive_timeout'] = '5 5'

#V-13726
node.set['nginx']['keepalive_timeout'] = '5 5'

default['nginx-hardening']['disable_symlinks'] = 'on'
default['nginx-hardening']['autoindex'] = 'off'

default['system_admin'] = 'root'
default['nginx_owner'] = 'nginx'

default['include_packages'] = ['audit']
default['remove_packages'] = ['postfix']

default['virtual_servers'] = ['/etc/nginx/sites-enabled/vserver1.conf']

default['root_folders'] = ['/usr/share/nginx/html/app1',
                           '/usr/share/nginx/html/app2']

default['cert_files'] = ['/etc/ssl/certs/DOD.crl',
                         '/etc/ssl/certs/dod-root-certs.pem',
                         '/etc/ssl/certs/dodeca2.pem',
                         '/etc/ssl/certs/dodeca.pem',
                         '/etc/ssl/certs/rel3_dodroot_2048.pem']

default['nginx_files'] = ['/etc/nginx/nginx.conf',
                         '/etc/nginx/mime.types',
                         '/etc/nginx/conf.d/90.hardening.conf',
                         '/var/run/nginx.pid']



