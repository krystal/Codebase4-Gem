# Codebase Gem
## Install & Configure the Codebase RubyGem

1. Install the gem on your computer

        $ gem install codebase4
1. Configure the Gem to include your access token which will enable you to log deployments.
   `YOUR_ACCOUNT_DOMAIN` is the domain you use to access your Codebase account and `YOUR_ACCESS_TOKEN`
   can be found on the Deployments page of a repository.

        $ codebase token YOUR_ACCOUNT_DOMAIN YOUR_ACCESS_TOKEN
1. Run a test to see if your token has been accepted fully

        $ codebase test YOUR_ACCOUNT_DOMAIN

## Configure Capistrano
1. In order to automatically track deployments, you just need to include the Codebase recipes 
   in your Capfile - these are provided by the gem you have already installed.

        require 'codebase/recipes'
