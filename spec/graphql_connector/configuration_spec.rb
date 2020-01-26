# frozen_string_literal: true

require 'spec_helper'

describe GraphqlConnector::Configuration do
  let(:config) { described_class.new }

  after do
    config.reset!
  end

  describe '#add_server' do
    subject(:add_server) do
      config.add_server(name: name, uri: uri, headers: headers)
    end
    let(:name) { 'Foo' }
    let(:uri) { 'http://foo.com' }
    let(:headers) { {} }

    it 'forwards params to BaseServerType build' do
      expect(GraphqlConnector::BaseServerType)
        .to receive(:build).with(name, uri, headers).and_call_original

      add_server
    end

    it 'collects built BaseServerType' do
      expect { add_server }
        .to change { config.base_server_types.count }.from(0).to(1)
    end
  end

  describe '#reset!' do
    subject(:reset!) { config.reset! }

    before do
      config.add_server(name: 'Foo', uri: 'Foo', headers: {})
    end

    it 'empties base_server_types collection' do
      expect { reset! }
        .to change { config.base_server_types.count }.from(1).to(0)
    end

    it 'removes BaseServerType' do
      expect { reset! }
        .to change { GraphqlConnector.const_defined?('Foo') }
        .from(true)
        .to(false)
    end
  end
end
