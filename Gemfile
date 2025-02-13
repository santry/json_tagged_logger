# frozen_string_literal: true

source "https://rubygems.org"

gemspec

rails_version = ENV.fetch("RAILS_VERSION", "7.2")

rails_constraint =
  if rails_version == "master"
    { github: "rails/rails" }
  else
    "~> #{rails_version}.0"
  end

gem "rails", rails_constraint

gem "bundler", ">= 2.2"
gem "minitest", ">= 5.16"
gem "rake", ">= 13.0"
gem "rubocop", "~> 1.71.2"
gem "rubocop-performance", "~> 1.23.1"
gem "rubocop-rails", "~> 2.29.1"
gem "rubocop-rake", "~> 0.6.0"
