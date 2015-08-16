Rack::AllowedHosts
==================

*Host-Header Injection Protection*

Usage
-----

### 1. Intall

```
gem 'rack-allowed_hosts'
```

### 2. Include Middleware

In `config/application.rb`, (if using Rails):

```
class MyApplication < Rails::Application
  ...
  if Rails.env == 'production'
    require 'rack/allowed_hosts'
    config.middleware.use Rack::AllowedHosts do

      # Allow root domain:
      allow 'myapp.com'

      # Allow our subdomains
      allow 'www.myapp.com', 'app.myapp.com'

      # Allow any subdomain with a wildcard
      allow '*.myapp.com'
      
      # Include subdomain from a configuration variable:
      # ENV['ALLOWED_HOSTS'] can be a string or an array of strings.
      allow ENV['ALLOWED_HOSTS']
    end
  end
```

Features
--------

### Pattern Matching

Wildcards (`*`) can be placed anywhere in the host pattern, and used to match any string, even including `.`.

So `*.mydomain.com` would match the following hosts:

* `platform.mydomain.com`
* `www.mydomain.com`
* `client.app.mydomain.com`

This pattern would **not** match the following hosts:

* `mydomain.com` - this pattern should be included separately if needed
* `mydomain.com.au`
* `mydomain.com.otherwebsite.com`

Warnings
--------

**Do not simply allow all hosts. This would defeat the purpose of using the middleware**

### Do not do this:

```
allow '*'
```

**...or this...**

```
allow '*.com'
```

**...or any of these...** (will enable anyone to spoof with `mydomain.com.maliciousdomain.com`)

```
allow 'mydomain.*'
allow 'mycomain.com.*'
```

