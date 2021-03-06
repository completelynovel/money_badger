# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "money_badger/version"

Gem::Specification.new do |s|
  s.name        = "money_badger"
  s.version     = MoneyBadger::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Oliver Brooks"]
  s.email       = ["oliver@completelynovel.com"]
  s.homepage    = ""
  s.summary     = "An extension to manage money transactions accurately"
  s.description = "adds acts_as_money option to ActiveRecord::Base to manage money in different currencies and precisions"

  s.rubyforge_project = "money_badger"

  s.required_rubygems_version = ">= 1.3.6"
  
  s.add_dependency "nokogiri"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "rails", "~> 3.2.0"
  s.add_development_dependency "sqlite3"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
