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
  s.date         = '2015-08-16'

  s.add_development_dependency "rspec"

end
