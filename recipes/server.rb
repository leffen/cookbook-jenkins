#
# Author:: Guilhem Lettron <guilhem.lettron@youscribe.com>
# Cookbook Name:: jenkins
# Recipe:: server
#
# Copyright 2013, Youscribe
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

include_recipe "java"

home_dir = node['jenkins']['server']['home']
user_name =  node['jenkins']['server']['user']
group = node['jenkins']['server']['group']

user user_name do
  home home_dir
  group group
  shell '/bin/bash'

  supports :manage_home => true
  action :create
end

data_dir = node['jenkins']['server']['data_dir']
plugins_dir = File.join(home_dir, "plugins")
log_dir = node['jenkins']['server']['log_dir']

[
  home_dir,
  data_dir,
  plugins_dir,
  log_dir
].each do |dir_name|
  directory dir_name do
    owner node['jenkins']['server']['user']
    group node['jenkins']['server']['group']
    mode '0700'
    recursive true
  end
end

node['jenkins']['server']['plugins'].each do |name|
  remote_file File.join(plugins_dir, "#{name}.hpi") do
    source "#{node['jenkins']['mirror']}/plugins/#{name}/latest/#{name}.hpi"
    owner node['jenkins']['server']['user']
    group node['jenkins']['server']['group']
    backup false
    action :create_if_missing
  end
end


log "restarting jenkins" do
  action :nothing
  notifies :restart, "service[jenkins]"
end

include_recipe "jenkins::server_#{node['jenkins']['server']['install_method']}"

ruby_block "block_until_operational" do
  block do
    until IO.popen("netstat -lnt").entries.select { |entry|
        entry.split[3] =~ /:#{node['jenkins']['server']['port']}$/
      }.size == 1
      Chef::Log.debug "service[jenkins] not listening on port #{node['jenkins']['server']['port']}"
      sleep 1
    end

    loop do
      url = URI.parse("#{node['jenkins']['server']['url']}/job/test/config.xml")
      res = Chef::REST::RESTRequest.new(:GET, url, nil).call
      break if res.kind_of?(Net::HTTPSuccess) or res.kind_of?(Net::HTTPNotFound)
      Chef::Log.debug "service[jenkins] not responding OK to GET / #{res.inspect}"
      sleep 1
    end
  end
  action :nothing
end

# Only restart if plugins were added
log "plugins updated, restarting jenkins" do
  only_if do
    # This file is touched on service start/restart
    pid_file = File.join(home_dir, "jenkins.start")
    if File.exists?(pid_file)
      htime = File.mtime(pid_file)
      Dir[File.join(plugins_dir, "*.hpi")].select { |file|
        File.mtime(file) > htime
      }.size > 0
    end
  end
  action :nothing
  if node['jenkins']['server']['init'] == "runit"
    notifies :restart, "runit_service[jenkins]", :immediately
  else
    notifies :restart, "service[jenkins]", :immediately
  end
  notifies :create, "ruby_block[block_until_operational]", :immediately
end
