require './lib/rack/allowed_hosts/version'

Gem::Specification.new do |s|

  s.name         = 'rack-allowed_hosts'
  s.summary      = 'Simple token translation middleware'

  s.description  = <<-EOF
    Rack::AllowedHosts allows you to whitelist the hostnames allowed to
    serve the site. This is helpful to protect against Host Header Injection.
    See: https://acunetix.com/vulnerabilities/web/host-header-attack
  EOF

  s.author       = 'Jeremy Blalock'
  s.files        = Dir["{lib}/**/*.rb"]
  s.version      = Rack::AllowedHosts::VERSION
  s.date         = '2017-01-06'
  s.license      = 'MIT'

  s.add_development_dependency "rspec"
  s.add_development_dependency "pry"
  s.add_development_dependency "pry-byebug"
end
