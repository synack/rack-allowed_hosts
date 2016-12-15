require 'spec_helper'

describe Rack::AllowedHosts do
  context 'initializing' do
    it 'can take a block' do
      instance = Rack::AllowedHosts.new app=nil do; end
      expect(instance.allowed_hosts.size).to eq 0
    end

    it 'records allowed hosts' do
      instance = Rack::AllowedHosts.new app=nil do
        allow '*.example.com', 'example.com'
      end
      expect(instance.allowed_hosts.size).to eq 2
    end

    it 'only records unique hosts' do
      instance = Rack::AllowedHosts.new app=nil do
        allow 'example.com', 'example.com'
      end
      expect(instance.allowed_hosts.size).to eq 1
    end
  end

  context '#matcher_for' do
    let(:instance) do
      Rack::AllowedHosts.new app=nil do; end
    end

    it 'returns a valid regex' do
      pattern = instance.matcher_for('example.com')
      expect(pattern).to be_a Regexp
    end

    it 'correctly parses a wildcard' do
      pattern = instance.matcher_for('*.example.com')
      expect(pattern.match('www.example.com')).not_to be_nil
    end

    context 'with rejex in strings' do
      it 'doesn’t treat periods as wildcards' do
        pattern = instance.matcher_for('abc.def.com')
        expect(pattern.match('abc-def.com')).to be_nil
      end

      it 'ignores "*" from rejex' do
        pattern = instance.matcher_for('abc*.def.com')
        expect(pattern.match('abcc.def.com')).to be_nil
      end

      it 'ignored "?" from rejex' do
        pattern = instance.matcher_for('abc?.def.com')
        expect(pattern.match('abc.def.com')).to be_nil
        expect(pattern.match('ab.def.com')).to be_nil
      end

      it 'ignores parentheses in rejex' do
        pattern = instance.matcher_for('ab(c).def.com')
        expect(pattern.match('abc.def.com')).to be_nil
      end
    end
  end

  context '#host_allowed?' do
    let(:instance) do
      Rack::AllowedHosts.new app=nil do; end
    end

    it 'allows hostname literals' do
      instance.allow 'example.com'
      expect(instance.host_allowed?('example.com')).to be true
    end

    it 'does not allow non-whitelisted domains' do
      expect(instance.host_allowed?('example.com')).to be false
    end

    context 'with wildcards' do
      it 'is allowed' do
        instance.allow '*.example.com'
        expect(instance.host_allowed?('www.example.com')).to be true
      end

      it 'is not equivalent to allowing naked domain' do
        instance.allow '*.example.com'
        expect(instance.host_allowed?('example.com')).to be false
      end

      it 'can match sub-subdomains' do
        instance.allow '*.example.com'
        expect(instance.host_allowed?('abc.def.example.com')).to be true
      end
    end

    context 'with leading' do
      it 'will fail' do
        instance.allow 'example.com'
        expect(instance.host_allowed?('www.example.com')).to be false
      end
    end

    context 'with trailing' do
      it 'will fail' do
        instance.allow 'example.com'
        expect(instance.host_allowed?('example.com.au')).to be false
      end
    end

    context 'with something in the middle' do
      it 'will fail' do
        instance.allow 'example.com'
        expect(instance.host_allowed?('example.othersite.com')).to be false
      end
    end

    context 'gracefully fails when' do
      it 'receives nil' do
        expect(instance.host_allowed?(nil)).to be false
      end

      it 'has invalid hostnames' do
        allow 'https://www.example.com'
        expect(instance.host_allowed?('www.example.com')).to be false
      end

      it 'receives leading dots' do
        instance.allow '.example.com'
        expect(instance.host_allowed?('www.example.com')).to be false
        expect(instance.host_allowed?('example.com')).to be false
      end
    end

    context 'works as expected when' do
      it 'receives trailing dots' do
        instance.allow 'example.com.'
        expect(instance.host_allowed?('example.com')).to be true
        expect(instance.host_allowed?('www.example.com')).to be false
      end
    end
  end

  context 'call' do
    let (:app) { double }
    let(:instance) do
      Rack::AllowedHosts.new(app) do
        allow 'example.com'
      end
    end

    context 'when HTTP_HOST and SERVER_NAME are nil' do
      it 'returns the forbidden response' do
        expect(app).to_not receive(:call)
        expect(instance.call({})).to eq Rack::AllowedHosts::FORBIDDEN_RESPONSE
      end
    end

    context 'when the host header is not an allowed host' do
      it 'returns the forbidden response' do
        expect(app).to_not receive(:call)
        expect(instance.call({ 'HTTP_HOST' => 'someotherdomain.com', 'SERVER_NAME' => 'someotherdomain.com' })).to eq Rack::AllowedHosts::FORBIDDEN_RESPONSE
      end
    end

    context 'when the host header is an allowed host' do
      it 'calls the next rack middleware' do
        expect(app).to receive(:call)

        instance.call({ 'HTTP_HOST' => 'example.com', 'SERVER_NAME' => 'example.com' })
      end
    end
  end
end
