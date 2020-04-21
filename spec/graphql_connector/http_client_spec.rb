# frozen_string_literal: true

require 'spec_helper'

describe GraphqlConnector::HttpClient do
  let(:client) { described_class.new(uri, headers) }
  let(:uri) { 'http://foo.bar/graphql' }
  let(:headers) { { 'Authorization' => 'Bearer Test' } }
  let(:body) { { data: { cars: [{ name: 'Audi' }] } }.to_json }

  before do
    allow(HTTParty).to receive(:post)
      .and_return(instance_double(HTTParty::Response, body: body))
  end

  describe '#query' do
    subject(:query) { client.query(model, conditions, selected_fields) }
    let(:model) { 'cars' }
    let(:conditions) { { 'name' => 'Audi' } }
    let(:selected_fields) { ['name'] }

    it 'forwards params to query builder' do
      expect(GraphqlConnector::QueryBuilder)
        .to receive(:new).with('query', model, conditions, selected_fields)
                         .and_call_original

      query
    end

    it 'resolves query_string via raw_query' do
      expect(client).to receive(:raw_query).with(String).and_call_original

      query
    end

    it { is_expected.to contain_exactly(OpenStruct) }

    it 'responds with correct value for name' do
      expect(query.first.name).to eq('Audi')
    end

    context 'when response with a single element' do
      let(:body) { { data: { cars: { name: 'Audi' } } }.to_json }

      it { is_expected.to be_a(OpenStruct) }

      it 'responds with correct value for name' do
        expect(query.name).to eq('Audi')
      end
    end
  end

  describe '#raw_query' do
    subject(:raw_query) { client.raw_query(query_string) }
    let(:query_string) { 'query { cars(name: "audi") { name } }' }

    it 'forwards params to HTTParty post' do
      expect(HTTParty)
        .to receive(:post)
        .with(uri,
              headers: headers,
              body: { query: query_string, variables: {} })

      raw_query
    end

    it { is_expected.to be_a(Hash) }

    context 'with explicite variables' do
      subject(:raw_query) do
        client.raw_query(query_string, variables: variables)
      end
      let(:query_string) do
        'query cars($name: String!) { cars(name: $String) { name } }'
      end
      let(:variables) { { name: 'audi' } }

      it 'forwards params and variables to HTTParty post' do
        expect(HTTParty)
          .to receive(:post)
          .with(uri,
                headers: headers,
                body: { query: query_string, variables: variables })

        raw_query
      end
    end

    context 'when response contains errors' do
      let(:body) { { errors: 'Cannot resolve for name' }.to_json }

      it 'raises a CustomAttributeError' do
        expect { raw_query }.to raise_error(CustomAttributeError)
      end
    end
  end

  describe '#mutation' do
    subject(:query) { client.mutation(model, inputs, selected_fields) }
    let(:model) { 'cars' }
    let(:inputs) { { 'name' => 'Audi' } }
    let(:selected_fields) { ['name'] }

    it 'forwards params to query builder' do
      expect(GraphqlConnector::QueryBuilder)
        .to receive(:new).with('mutation', model, inputs, selected_fields)
                         .and_call_original

      query
    end

    it 'resolves query_string via raw_query' do
      expect(client).to receive(:raw_query).with(String).and_call_original

      query
    end

    it { is_expected.to contain_exactly(OpenStruct) }

    it 'responds with correct value for name' do
      expect(query.first.name).to eq('Audi')
    end

    context 'when response with a single element' do
      let(:body) { { data: { cars: { name: 'Audi' } } }.to_json }

      it { is_expected.to be_a(OpenStruct) }

      it 'responds with correct value for name' do
        expect(query.name).to eq('Audi')
      end
    end
  end
end
