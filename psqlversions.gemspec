
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'psqlversions/version'

Gem::Specification.new do |spec|
  spec.name          = 'psqlversions'
  spec.version       = Psqlversions::VERSION
  spec.authors       = ['Cameron Seebach']
  spec.email         = ['cameron.seebach@lendinghome.com']

  spec.summary       = 'Manage versions of your local Postgres databases more effectively.'
  spec.description   = 'Requires the Postgres command line tools.'
  spec.homepage      = 'https://github.com/cseebach-lh/psqlversions'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = ['psqlversions']
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_runtime_dependency "thor"
  spec.add_runtime_dependency "daybreak"
  spec.add_runtime_dependency "terminal-table"
end
