Gem::Specification.new do |s|

  s.name            = 'logstash-input-sqliteonec'
  s.version         = '0.1.4'
  s.licenses        = ['Apache License (2.0)']
  s.summary         = "Read rows from an sqlite database in 1C Rnterprise"
  s.description     = "Plugin for read event log from 1C sqlite format"
  s.authors         = ["Andrew Keinih, Alexey Lustin, Denis Bogatyrev, Pavel Tichomirov"]
  s.email           = 'support@vanessa.services'
  s.homepage        = "http://www.elastic.co/guide/en/logstash/current/index.html"
  s.require_paths = ["lib"]

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']

  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "input" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core", ">= 3.0.0", "< 6.0.0"

  s.add_runtime_dependency 'sequel'
  s.add_runtime_dependency 'jdbc-sqlite3'

  s.add_development_dependency 'logstash-devutils'
  s.add_development_dependency 'logstash-codec-plain'
end

