require 'date'

Gem::Specification.new do |s|
  s.authors                = ['Lee Briggs']
  s.version                = '0.0.1'
  s.date                   = Date.today.to_s
  s.description            = 'A script to create sensu events from running arbitrary commands. Ideal for cronjobs and other asynchronous commands'
  s.email                  = '<lee@leebriggs.co.uk>'
  s.homepage               = 'https://github.com/jaxxstorm/sensu-wrapper'
  s.license                = 'MIT'
  s.metadata               = { 'maintainer'         => 'Lee Briggs',
                               'development_status' => 'active',
                               'production_status'  => 'unstable - testing recommended',
                               'release_draft'      => 'false',
                               'release_prerelease' => 'false'
                              }
  s.name                   = 'sensu-wrapper'
  s.platform               = Gem::Platform::RUBY
  s.required_ruby_version  = '>= 1.9.3'
  s.has_rdoc               = false
  s.summary                = 'A crappy ruby script to send shell command results to sensu'
  s.add_runtime_dependency    'trollop', '~> 2.1'
  s.files                  = Dir.glob('{bin,lib}/**/*') + %w(sensu-wrapper.gemspec README.md)
  s.executables            = Dir.glob('bin/**/*').map { |file| File.basename(file) }
  s.require_paths          = ['lib']
end
