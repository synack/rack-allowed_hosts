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

end
