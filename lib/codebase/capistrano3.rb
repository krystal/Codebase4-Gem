namespace :codebase do

  desc "Logs the deployment of your Codebase repository"
  task :log_deployment do
    repository = fetch(:repo_url)
    previous_revision = fetch(:previous_revision)
    current_revision = fetch(:current_revision)
    environment = fetch(:stage)
    branch = fetch(:branch)
    roles = roles(:all)
    servers = roles.map{|r| r.hostname }

    if previous_revision == current_revision
      puts "\e[31m    The old revision & new revision are the same - you didn't deploy anything new. Skipping logging.\e[0m"
      next
    end

    cmd = ["cb deploy #{previous_revision or "0000000000000000000000000000000000000000"} #{current_revision}"]
    
    cmd << "-s #{servers.uniq.join(',') rescue ''}"
    cmd << "-b #{branch}"
    cmd << "-e #{environment}"
    
    ## get the repo and project name etc...
    account, project, repo = nil, nil, nil
    case repository
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

  after 'deploy:finished', 'codebase:log_deployment'

end