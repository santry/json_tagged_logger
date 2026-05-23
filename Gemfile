source "https://rubygems.org"

gemspec

rails_version = ENV.fetch("RAILS_VERSION", "8.1")

if rails_version == "master"
  rails_constraint = { github: "rails/rails" }
else
  rails_constraint = "~> #{rails_version}.0"
end

gem "rails", rails_constraint

# Minitest 6 extracted Mock into the separate minitest-mock gem, which
# requires Ruby >= 3.1. On older Rubies, stay on minitest 5.x where Mock
# is still bundled.
if RUBY_VERSION >= "3.2"
  gem "minitest-mock", ">= 5.27"
else
  gem "minitest", "< 6"
end
