require 'uri'
require 'net/https'
require 'yaml'
require 'rubygems'
require 'json'
require 'codebase/config'

module Codebase

  class << self

    # Return the current configuration for the current machine
    def config
      @config ||= Config.init
    end

    ## Make an HTTP request
    def request(url, data)
      uri = URI.parse(url)
      req = Net::HTTP::Post.new(uri.path)
      req.set_form_data(data)
      res = Net::HTTP.new(uri.host, uri.port)

      if uri.scheme == 'https'
        res.use_ssl = true
      end

      case res = res.request(req)
      when Net::HTTPSuccess
        JSON.parse(res.body)
      when Net::HTTPBadRequest
        error = JSON.parse(res.body)
        raise error.inspect
      else
        raise "An HTTP error occured (#{res.class})"
      end
    end

  end

end

