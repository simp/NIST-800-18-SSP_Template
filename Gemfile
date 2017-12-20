# Variables:
#
gem_sources   = ENV.key?('GEM_SOURCES') ? ENV['GEM_SOURCES'].split(/[, ]+/) : ['https://rubygems.org']

gem_sources.each { |gem_source| source gem_source }

gem 'rake'
gem 'inifile'

group :debug do
  gem 'pry'
end

#vim: set syntax=ruby:ts=2:expandtab
