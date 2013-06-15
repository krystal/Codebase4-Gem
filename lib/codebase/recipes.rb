Capistrano::Configuration.instance(:must_exist).load do

  after 'deploy:create_symlink', 'codebase:log_deployment'

  namespace :codebase do
    desc "Logs the deployment of your Codebase 4 repository"
    task :log_deployment do

      if previous_revision == current_revision
        puts "\e[31m    The old revision & new revision are the same - you didn't deploy anything new. Skipping logging.\e[0m"
        next
      end

      cmd = ["cb deploy #{previous_revision or "0000000000000000000000000000000000000000"} #{current_revision}"]
      
      set :branch, (respond_to?(:branch) ? branch : 'master')
      
      if respond_to?(:environment)
        set :environment, environment
      elsif respond_to?(:rails_env)
        set :environment, rails_env
      end
      
      cmd << "-s #{roles.values.collect{|r| r.servers}.flatten.collect{|s| s.host}.uniq.join(',') rescue fetch(:rails_env)}"
      cmd << "-b #{branch}"
      cmd << "-e #{environment}" if respond_to?(:environment)
      
      ## get the repo and project name etc...
      account, project, repo = nil, nil, nil
      case fetch(:repository)
      when /git\@codebasehq.com\:(.+)\/(.+)\/(.+)\.git\z/
        account, project, repo = $1, $2, $3
      when /ssh:\/\/.+\@codebasehq.com\/(.+)\/(.+)\/(.+)\.hg\z/
        account, project, repo = $1, $2, $3
      when /https?:\/\/.+\@(.+)\.codebasehq.com\/(.+)\/(.+)\.(?:hg|svn)\z/
        account, project, repo = $1, $2, $3
      when /https?:\/\/(?:.+\@)?(.+)\.svn\.codebasehq.com\/(.+?)\/(.+?)(?:\/.*)\z/
        account, project, repo = $1, $2, $3
      else
        puts "! Repository path not supported by deployment logging"
        next
      end

      cmd << "-r #{project}:#{repo}"
      cmd << "-h #{account}.codebasehq.com"
      cmd << "--protocol https"

      puts "   running: #{cmd.join(' ')}"
      system(cmd.join(' ') + "; true")

    end
  end

end
