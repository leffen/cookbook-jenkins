


jenkins_url = node['jenkins']['server']['url']
admin_email = node['jenkins']['server']['admin-email']
recipient_list = node['jenkins']['server']['admin-email']
list_id = node['jenkins']['server']['host']

config_files = {
    'hudson.plugins.ansicolor.AnsiColorBuildWrapper' => {},
    'jenkins.model.JenkinsLocationConfiguration' =>  {'jenkins_url' => jenkins_url, 'admin_email' => admin_email},
    'com.cloudbees.jenkins.GitHubPushTrigger' => {},
    'hudson.maven.MavenModuleSet' => {},
    'hudson.model.UpdateCenter' => {},
    'hudson.plugins.emailext.ExtendedEmailPublisher' =>
        {
            'jenkins_url' => "#{jenkins_url}/",
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
  config.merge!('source' => "configs/#{config_file}.xml.erb")
  config.merge!('cookbook' => "cookbook-jenkins")
end

jenkins_config_set "config_set" do
  private_key node['jenkins']['private_key'] if node['jenkins']['private_key']
  configs config_files
end


log "restarting jenkins" do
  action :nothing
  notifies :restart, "service[jenkins]"
end
