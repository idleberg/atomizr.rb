Gem::Specification.new do |s|
  s.name        = 'atomizr'
  s.version     = '0.17.3'
  s.date        = '2016-08-21'
  s.summary     = "Converts Sublime Text snippets and completions into Atom format"
  s.description = "A command-line tool to convert Sublime Text snippets and completions, as well as and TextMate snippets into Atom snippets"
  s.authors     = ["Jan T. Sott"]
  s.files       = ["lib/atomizr.rb"]
  s.homepage    =
    'https://github.com/idleberg/ruby-atomizr'
  s.license       = 'MIT'

  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "bundler", "~> 1.12.5"
  s.add_dependency "json", "~> 2.0.2"
  s.add_dependency "nokogiri", "~> 1.6.7.2"
end