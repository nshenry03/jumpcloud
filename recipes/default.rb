#
# Cookbook Name:: jumpcloud
# Recipe:: default
#
# Copyright 2013, Standing Cloud
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

if Chef::Config[:solo]
  Chef::Log.info("#{cookbook_name}::#{recipe_name} is intended for use with
                 Chef Server, use #{cookbook_name}::default with Chef Solo.")
  return
end

db_name = node['jumpcloud']['databag_name']
dbi_name = node['jumpcloud']['databagitem_name']

if !File.exists?('/etc/chef/encrypted_data_bag_secret')
  Chef::Log.fatal('File does not exist: /etc/chef/encrypted_data_bag_secret')
  raise "You must upload the file used to decrypt the '#{dbi_name}' item from
         the '#{db_name}' data bag to this location."
end

jc_creds = Chef::EncryptedDataBagItem.load(db_name, dbi_name)

connection_key = jc_creds['key']

%w[curl sudo bash].each do |pkg|
  package pkg
end


remote_file "#{Chef::Config[:file_cache_path]}/kickstart.sh" do
  source 'https://kickstart.jumpcloud.com/Kickstart'
  mode 00700
  headers 'x-connect-key' => connection_key
  not_if {
    ::Dir.exists?('/opt/jc')
  }
end

execute 'agent_install' do
  command "sudo bash #{Chef::Config[:file_cache_path]}/kickstart.sh"
  path [
    '/sbin',
    '/bin',
    '/usr/sbin',
    '/usr/bin'
  ]
  timeout 600
  not_if {
    ::Dir.exists?('/opt/jc')
  }
end
