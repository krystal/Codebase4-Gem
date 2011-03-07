require 'codebase'

module Codebase
  class CLI
    
    class Error < StandardError; end
    
    def self.invoke(*args)
      command = args.shift
      cmd = self.new
      if command.nil?
        raise Error, "usage: codebase [command] *args"
      elsif cmd.respond_to?(command)
        cmd.send(command, *args)
      else
        raise Error, "Command not found"
      end
    rescue Error => e
      $stderr.puts e.message
      Process.exit(1)
    rescue ArgumentError
      $stderr.puts "Invalid arguments provided for command ('#{command}')"
      Process.exit(1)
    end
    
    def token(account_name, token)
      Codebase.config.set(:tokens, Hash.new) unless Codebase.config.tokens.is_a?(Hash)
      Codebase.config.tokens[account_name] = token
      Codebase.config.save
      puts "Added token for '#{account_name}'"
    end
    
    def deploy(start_ref, end_ref, *options)
      options = options_to_hash(options)
      
      hash = {
        :start_ref => start_ref,
        :end_ref => end_ref,
        :environment => options['e'] || options['environment'],
        :servers => options['s'] || options['servers'],
        :branch => options['b'] || options['branch']
      }
      
      host = options['h'] || options['host']
      repo = options['r'] || options['repo']
      
      raise Error, "You must specify at least one server using the -s or --servers flag" if blank?(hash[:servers])
      raise Error, "You must specify the repo using the -r or --repo flag (as project:repo)" if blank?(repo)
      raise Error, "You must specify the host using the -h or --host flag" if blank?(host)
      
      project, repo = repo.split(':')
      
      puts "Sending deployment information to #{host} (project: '#{project}' repo: '#{repo}')"
      
      puts "   Commits......: #{hash[:end_ref]} ... #{hash[:start_ref]}"
      puts "   Environment..: #{hash[:environment] || '-'}"
      puts "   Branch.......: #{hash[:branch] || '-'}"
      puts "   Server(s)....: #{hash[:servers]}"
      
      token = Codebase.config.tokens.is_a?(Hash) && Codebase.config.tokens[host]
      if token.nil?
        raise Error, "This account has no token configured locally, use 'codebase token [account] [token]' to configure it"
      end
      
      puts "   Token........: #{token[0,7]}******"
      hash[:access_token] = token
      
      protocol = options['protocol'] || 'http'
      
      Codebase.request("#{protocol}://#{host}/projects/#{project}/repositories/#{repo}/deployments/add", hash)
      puts "Deployment added successfully"
    end
    
    private
    
    def options_to_hash(options)
      hash = Hash.new
      key = nil
      for opt in options
        if opt =~ /\A\-/
          key = opt
        else
          next if key.nil?
          hash[key.gsub(/\A-+/, '')] = opt
          key = nil
        end
      end
      hash
    end
    
    def blank?(*array)
      array.any? {|a| a.nil? || a.length == 0 }
    end
    
  end
end
