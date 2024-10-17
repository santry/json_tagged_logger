source "https://rubygems.org"

gemspec

rails_version = ENV.fetch("RAILS_VERSION", "7.2")

if rails_version == "master"
  rails_constraint = { github: "rails/rails" }
else
  rails_constraint = "~> #{rails_version}.0"
end

gem "rails", rails_constraint
