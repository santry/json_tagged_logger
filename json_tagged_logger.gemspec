lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'json_tagged_logger/version'

Gem::Specification.new do |s|
  s.name = "json_tagged_logger"
  s.version = JsonTaggedLogger::VERSION
  s.platform = Gem::Platform::RUBY
  s.summary = "JSON Tagged Log Formatter"
  s.description = "Formatter for logging with ActiveSupport::TaggedLogging as JSON"
  s.authors = ["Sean Santry"]
  s.email = ["sean@santry.us"]
  s.homepage = "https://github.com/santry/json_tagged_logger"
  s.license = "MIT"

  s.files = Dir["{lib}/**/*.rb", "LICENSE", "README.md"]
  s.require_path = "lib"

  s.add_development_dependency 'bundler', '>= 2.2'
  s.add_development_dependency 'minitest', '>= 5.16'
  s.add_development_dependency 'rake', '>= 13.0'

  s.add_runtime_dependency 'activesupport', '>= 5.2'
  s.add_runtime_dependency 'actionpack', '>= 5.2'
  s.add_runtime_dependency 'activesupport-tagged_logging'

  s.required_ruby_version = '>= 2.7'
end
