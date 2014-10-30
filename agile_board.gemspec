$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "agile_board/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "agile_board"
  s.version     = AgileBoard::VERSION
  s.authors     = ["Nicolas Meylan"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "An agile board plugin for RORganize app."
  s.description = "This agile board allow projects' members to write user stories, define sprint, link user stories with issues, group stories into epics..."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.6"

end
