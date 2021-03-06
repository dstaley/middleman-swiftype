# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "middleman-swiftype"
  s.version     = "0.0.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Leon Bogaert", "Dylan Staley"]
  s.email       = ["leonbogaert@gmail.com", "staley.dylan@gmail.com"]
  s.homepage    = "https://github.com/dstaley/middleman-swiftype"
  s.summary     = %q{A Swiftype JSON generator for Middleman}
  # s.description = %q{A longer description of your extension}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # The version of middleman-core your extension depends on
  s.add_runtime_dependency("middleman-core", [">= 3.0"])

  # Additional dependencies
  s.add_runtime_dependency("swiftype", ["~> 1.1.0"])
  s.add_runtime_dependency("nokogiri", [">= 1.3.3"])
end
