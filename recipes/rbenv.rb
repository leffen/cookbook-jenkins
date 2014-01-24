home_dir = node['jenkins']['server']['home']
user_name =  node['jenkins']['server']['user']
group = node['jenkins']['server']['group']

git "#{home_dir}/.rbenv" do
  repository 'https://github.com/sstephenson/rbenv.git'
  reference 'master'
  user user_name
  group group
  action :sync
end

directory "#{home_dir}/.rbenv/plugins/" do
  owner user_name
  group group
end


git "#{home_dir}/.rbenv/plugins/ruby-build" do
  repository 'https://github.com/sstephenson/ruby-build.git'
  reference 'master'
  user user_name
  group group
  action :sync
end

base_packages = %w{ tar bash curl git-core }
cruby_packages = %w{ build-essential bison openssl libreadline6 libreadline6-dev
        zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0
        libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev autoconf
        libc6-dev ssl-cert subversion }
jruby_packages =  %w{ make g++ }

(base_packages + cruby_packages + jruby_packages).each do |pkg|
  package pkg
end

# extendedsuggestion ['2.1.0','2.0.0-p353','1.9.3-p484', 'jruby-1.7.2']
rubies = node['jenkins']['rbenv']['rubies'] || ['2.0.0-p353']

rubies.each do |rubie|
  bash "ruby-build #{rubie}" do
    user user_name
    group group
    code <<CMD
export PATH="#{home_dir}/.rbenv/bin:$PATH"
export RBENV_ROOT="#{home_dir}/.rbenv"
eval "$(rbenv init -)"
rbenv install #{rubie}
CMD
    not_if { File.exist?("#{home_dir}/.rbenv/versions/#{rubie}") }
    environment ({'HOME' => home_dir})
  end
end