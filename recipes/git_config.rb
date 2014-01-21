home_dir = node['jenkins']['server']['home']


execute "set git user.email" do
  command "git config --global user.email '#{node["git"]["email"]}'"
  not_if "git config -l | grep 'user.email=#{node["git"]["email"]}'", :environment => {"HOME"=>home_dir}
  user "jenkins"
  environment({"HOME"=>home_dir})
  cwd home_dir
end

execute "set git user.name" do
  command "git config --global user.name '#{node["git"]["name"]}'"
  not_if "git config -l | grep 'user.name=#{node["git"]["name"]}'", :environment => {"HOME"=>home_dir}
  user "jenkins"
  environment({"HOME"=>home_dir})
  cwd home_dir
end
