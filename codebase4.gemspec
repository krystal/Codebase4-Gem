Gem::Specification.new do |s|
  s.name = 'codebase4'
  s.version = "1.0.16"
  s.platform = Gem::Platform::RUBY
  s.summary = "The RubyGem for Codebase v4 Deployment Tracking (replaces previous codebase gems)"
  s.files = Dir.glob("{bin,lib}/**/*")
  s.require_path = 'lib'
  s.has_rdoc = false
  s.bindir = "bin"
  s.executables << "codebase"
  s.executables << "cb"
  s.add_dependency('json', '>= 1.1.5')
  s.author = "Adam Cooke"
  s.email = "adam@atechmedia.com"
  s.homepage = "http://atechmedia.com"
end
