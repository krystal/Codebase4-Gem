configuration = Capistrano::Configuration.respond_to?(:instance) ?
  Capistrano::Configuration.instance(:must_exist) :
  Capistrano.configuration(:must_exist)

configuration.load do

  after 'deploy:finalise', 'codebase:log_deployment'

  namespace :codebase do
    desc "Logs the deployment of your Codebase 4 repository"
    task :log_deployment do

      ## get the revision deployed on the remote
      old_revision, new_revision = nil
      run "git --git-dir=#{deploy_to}/.git rev-list rollback -n 1" do |ch, st, data|
        old_revision = data.chomp
      end
      
      run "git --git-dir=#{deploy_to}/.git rev-list deploy -n 1" do |ch, st, data|
        new_revision = data.chomp
      end
      
      if old_revision == new_revision
        puts "\e[31m    The old revision & new revision are the same - you didn't deploy anything new. Skipping logging.\e[0m"
        next
      end
      
      cmd = ["cb deploy #{old_revision} #{new_revision}"]
      
      cmd << "-s #{roles.values.collect{|r| r.servers}.flatten.collect{|s| s.host}.uniq.join(',') rescue ''}"
      cmd << "-e #{fetch(:environment)}"
      cmd << "-b #{fetch(:branch)}"
      
      ## get the repo and project name etc...
      if fetch(:repository) =~ /git\@codebasehq.com\:(\w+)\/(\w+)\/(\w+)\.git\z/
        account, project, repo = $1, $2, $3
        cmd << "-r #{project}:#{repo}"
        cmd << "-h #{account}.codebasehq.com"
        cmd << "--protocol https"
      else
        puts "! Repository path not supported by deployment logging"
        next
      end
      puts "   running: #{cmd.join(' ')}"
      system(cmd.join(' ') + "; true")

    end
  end

end
