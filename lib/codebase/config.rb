module Codebase
  class Config

    def self.init(path = File.join(ENV['HOME'], '.codebase4'))
      if File.exist?(path)
        self.new(path, YAML.load_file(path))
      else
        self.new(path)
      end
    end

    def initialize(filename, hash = {})
      @filename = filename
      @hash = hash
    end

    def method_missing(name)
      @hash[name.to_s]
    end

    def set(name, value)
      @hash[name.to_s] = value
      save
      value
    end

    def save
      File.open(@filename, 'w') { |f| f.write(YAML.dump(@hash)) }
    end

  end
end
