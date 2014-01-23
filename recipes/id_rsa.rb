username = node['jenkins']['server']['user']
home_dir = node['jenkins']['server']['home']


directory "#{home_dir}/.ssh" do
  mode 0700
  owner "jenkins"
end

chef_gem 'httparty'

# create their ssh key
execute 'generate ssh key for deploy' do
  user 'deploy'
  creates '/home/deploy/.ssh/id_rsa'
  command 'ssh-keygen -t rsa -q -f /home/deploy/.ssh/id_rsa -P ""'
  notifies :create, "ruby_block[add_ssh_key_to_bitbucket]"
  notifies :run, "execute[add_bitbucket_to_known_hosts]"
end


execute "copy id_rsa" do
  destination_path = "#{home_dir}/.ssh/id_rsa"
  source_path = "/home/#{username}/.ssh/id_rsa"
  files = "#{source_path} #{destination_path}"
  command "cp #{files}"
  only_if { (::File.exists?(source_path)) && !system("diff -q #{files}") }
end

file "#{home_dir}/.ssh/id_rsa" do
  mode 0600
  owner "jenkins"
end

file "#{home_dir}/.ssh/known_hosts" do
  mode 0600
  owner "jenkins"
end

#execute "add github to known hosts if necessary" do
#  github_string = 'github.com,207.97.227.239 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ=='
#  command "echo '#{github_string}' >> #{node["jenkins"]["home"]}/.ssh/known_hosts"
#  not_if "grep '#{github_string}' #{node["jenkins"]["home"]}/.ssh/known_hosts"
#end