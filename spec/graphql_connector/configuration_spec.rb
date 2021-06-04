# frozen_string_literal: true

require 'spec_helper'

describe GraphqlConnector::Configuration do
  let(:config) { described_class.new }

  after do
    config.reset!
  end

  shared_examples 'Build BaseServerType' do
    it 'collects built BaseServerType' do
      expect { add_server }
        .to change { config.base_server_types.count }.from(0).to(1)
    end
  end

  describe '#add_server' do
    subject(:add_server) do
      config.add_server(name: name, uri: uri, headers: headers)
    end
    let(:name) { 'Foo' }
    let(:uri) { 'http://foo.com' }
    let(:headers) { {} }
    let(:connector) { {} }

    it 'forwards params to BaseServerType build' do
      expect(GraphqlConnector::BaseServerType)
        .to receive(:build)
        .with(name, uri, headers, connector)
        .and_call_original

      add_server
    end

    it_behaves_like 'Build BaseServerType'

    context 'no headers set' do
      let(:headers) { nil }

      it_behaves_like 'Build BaseServerType'
    end

    context 'no connector set' do
      let(:connector) { nil }

      it_behaves_like 'Build BaseServerType'
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

    it 'removes service class inclusion Query' do
      expect { reset! }
        .to change { GraphqlConnector.const_defined?('Foo::Query') }
        .from(true)
        .to(false)
    end
  end
end
