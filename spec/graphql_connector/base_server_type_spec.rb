# frozen_string_literal: true

require 'spec_helper'

describe GraphqlConnector::BaseServerType do
  let(:type) { described_class }

  describe '.build' do
    subject(:build) { type.build(name, uri, headers) }
    let(:name) { 'Foo' }
    let(:uri) { 'http://bar.com/api/graphql' }
    let(:headers) { { 'Authorization' => 'Bearer Test' } }

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

    context 'when using name again' do
      let(:another_build) do
        type.build(name, 'http://bar.com/graphql', {})
      end

      before do
        build
      end

      it 'raises an ClientTypeAlreadyExistsError' do
        expect { another_build }
          .to raise_error(GraphqlConnector::BaseServerTypeAlreadyExistsError,
                          /name/)
      end
    end
  end
end
