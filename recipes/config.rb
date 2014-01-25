

home_dir = node['jenkins']['server']['home']
user_name =  node['jenkins']['server']['user']
group = node['jenkins']['server']['group']

jenkins_url = node['jenkins']['server']['url']
admin_email = node['jenkins']['server']['admin-email']
recipient_list = node['jenkins']['server']['admin-email']
list_id = node['jenkins']['server']['host']

config_files = {
    'hudson.plugins.ansicolor.AnsiColorBuildWrapper' => {},
    'jenkins.model.JenkinsLocationConfiguration' =>  {'jenkins_url' => jenkins_url, 'admin_email' => admin_email},
    'hudson.maven.MavenModuleSet' => {},
    'hudson.model.UpdateCenter' => {},
    'hudson.plugins.emailext.ExtendedEmailPublisher' =>
        {
            'jenkins_url' => jenkins_url,
            'admin_email' => admin_email,
            'list_id' => list_id
        },
    'hudson.plugins.git.GitTool' => {},
    'hudson.tasks.Ant' => {},
    'hudson.tasks.Maven' => {},
    'hudson.tasks.Shell' => {},
    'org.jenkinsci.plugins.mavenrepocleaner.MavenRepoCleanerProperty' => {},
    'hudson.triggers.SCMTrigger' => {},
    'hudson.tasks.Mailer' =>
        {
            'hudson_url' => jenkins_url,
            'admin_email' => admin_email,
            'list_id' => list_id,
            'reply_to_address' => recipient_list,
            'smtp_host' => node['jenkins']['smtp']['host'],
            'smtp_port' => node['jenkins']['smtp']['port'],
            'smtp_auth_password' => node['jenkins']['smtp']['password'],
            'smtp_auth_username' => node['jenkins']['smtp']['username']
        },
    'hudson.scm.CVSSCM' => {},
    'hudson.scm.SubversionSCM' => {}
}

config_files.each_pair do |config_file, config|
  file_name = "#{home_dir}/#{config_file}.xml"
  template file_name do
    source "configs/#{config_file}.xml.erb"
    owner user_name
    group group
    mode 0644
    variables(config)
    not_if { ::File.exists?(file_name) }
  end
end




log "restarting jenkins" do
  action :nothing
  notifies :restart, "service[jenkins]"
end
