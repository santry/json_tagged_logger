require File.expand_path("../lib/json_tagged_logger/version", __FILE__)

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
end
