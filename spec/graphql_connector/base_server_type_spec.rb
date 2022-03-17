# frozen_string_literal: true

require 'spec_helper'

describe GraphqlConnector::BaseServerType do
  let(:type) { described_class }

  describe '.build' do
    subject(:build) { type.build(name, uri, headers, connector, httparty_adapter_options) }
    let(:name) { 'Foo' }
    let(:uri) { 'http://bar.com/api/graphql' }
    let(:headers) { { 'Authorization' => 'Bearer Test' } }
    let(:connector) { { base: Class.new, method: 'to_s' } }
    let(:httparty_adapter_options) { { timeout: 3 } }

    after do
      GraphqlConnector.send :remove_const, name
    end

    it { is_expected.to eq(GraphqlConnector::Foo) }

    it 'injects query method of http_client' do
      build

      expect(GraphqlConnector::Foo).to respond_to(:query)
    end

    it 'injects raw_query method of http_client' do
      build

      expect(GraphqlConnector::Foo).to respond_to(:raw_query)
    end

    it 'injects mutation method of http_client' do
      build

      expect(GraphqlConnector::Foo).to respond_to(:mutation)
    end

    it 'creates a service class module' do
      expect { build }
        .to change { Object.const_defined?('GraphqlConnector::Foo::Query') }.from(false).to(true)
    end

    it 'created service class module has extension injection' do
      build

      expect(GraphqlConnector::Foo::Query).to respond_to(:extended)
    end

    context 'when using name again' do
      let(:another_build) do
        type.build(name, 'http://bar.com/graphql', {})
      end

      before do
        build
      end

      it 'raises an ClientTypeAlreadyExistsError' do
        expect { another_build }
          .to raise_error(GraphqlConnector::BaseServerTypeAlreadyExistsError, /name/)
      end
    end
  end
end
