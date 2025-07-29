# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

branch = ENV.fetch("SOLIDUS_BRANCH", "main")
solidus_git, solidus_frontend_git = if ["master", "main", "v3.2"].include?(branch)
  %w[solidusio/solidus solidusio/solidus_frontend]
else
  %w[solidusio/solidus] * 2
end
gem "solidus", github: solidus_git, branch: branch
gem "solidus_frontend", github: solidus_frontend_git, branch: branch

# Needed to help Bundler figure out how to resolve dependencies,
# otherwise it takes forever to resolve them.
# See https://github.com/bundler/bundler/issues/6677
gem "rails", ">0.a"

# Provides basic authentication functionality for testing parts of your engine
gem "solidus_auth_devise"
gem "solidus_dev_support"

case ENV["DB"]
when "mysql"
  gem "mysql2"
when "postgresql"
  gem "pg"
else
  gem "sqlite3"
end

group :test do
  gem "rails-controller-testing"
  gem "rspec-activemodel-mocks"
  gem "rubocop-rspec"
  gem "rubocop-rails"
end

gemspec
