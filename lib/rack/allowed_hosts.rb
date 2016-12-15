require 'rack/allowed_hosts/version'

# Rack::AllowedHosts
module Rack
  class AllowedHosts

    FORBIDDEN_RESPONSE = [403, {'Content-Type' => 'text/html'}, ['<h1>403 Forbidden</h1>']]

    attr_reader :allowed_hosts

    def initialize(app, &block)
      @app = app
      @allowed_hosts = []

      # Call the block
      instance_eval(&block)
    end

    def allow(*hosts)
      # Also allow the for `allow ['host-a.com', 'host-b.com']` etc.
      if hosts.size == 1 && hosts[0].is_a?(Array)
        hosts = hosts[0]
      end

      hosts.each do |host|
        matcher = matcher_for(host)
        @allowed_hosts << matcher unless @allowed_hosts.include? matcher
      end
    end

    def call(env)
      http_host = env['HTTP_HOST']

      unless http_host.nil?
        http_host = http_host.split(':').first
      end

      host_values = [
        http_host,
        env['SERVER_NAME']
      ].uniq

      host_values.each do |host|
        unless host_allowed?(host)
          return FORBIDDEN_RESPONSE
        end
      end

      # Fetch the result
      @app.call(env)
    end

    def host_allowed?(host)
      return false if host.nil?

      @allowed_hosts.each do |pattern|
        return true if pattern.match host
      end

      false
    end

    def matcher_for(host)
      host = host.gsub(/\.\Z/, '')
      parts = host.split('.')
      pattern = nil
      parts.each do |part|
        if pattern.nil?
          pattern = prepared_part(part)
        else
          pattern = /#{pattern}\.#{prepared_part(part)}/
        end
      end
      /\A#{pattern}\Z/
    end

    def prepared_part(part)
      if part == '*'
        /.*/
      else
        Regexp.quote(part)
      end
    end
  end
end
