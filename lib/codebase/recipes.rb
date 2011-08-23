Capistrano::Configuration.instance(:must_exist).load do

  after 'deploy:symlink', 'codebase:log_deployment'

  namespace :codebase do
    desc "Logs the deployment of your Codebase 4 repository"
    task :log_deployment do

      if previous_revision == current_revision
        puts "\e[31m    The old revision & new revision are the same - you didn't deploy anything new. Skipping logging.\e[0m"
        next
      end

      cmd = ["cb deploy #{previous_revision} #{current_revision}"]
      
      branch = respond_to?(:branch) ? branch : 'master'
      
      if respond_to?(:environment)
        environment = environment
      elsif respond_to(:rails_env)
        environment = rails_env
      end
      
      cmd << "-s #{roles.values.collect{|r| r.servers}.flatten.collect{|s| s.host}.uniq.join(',') rescue ''}"
      cmd << "-b #{branch}"
      cmd << "-e #{environment}" if respond_to?(:environment)
      
      ## get the repo and project name etc...
      if fetch(:repository) =~ /git\@codebasehq.com\:(.+)\/(.+)\/(.+)\.git\z/
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
