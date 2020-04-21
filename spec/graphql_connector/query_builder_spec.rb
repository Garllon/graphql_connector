# frozen_string_literal: true

require 'spec_helper'

module GraphqlConnector
  describe QueryBuilder do
    let(:builder) do
      described_class.new(type, model, inputs, selected_fields)
    end
    let(:type) { 'query' }
    let(:model) { 'product' }
    let(:inputs) { { id: 1 } }
    let(:selected_fields) { %w[id name] }
    subject { builder.create }

    let(:expect_result) do
      <<-STRING
      query {
        product(id: 1) {
          id name
        }
      }
      STRING
    end

    it { is_expected.to eq(expect_result) }

    context 'with mutation type' do
      let(:type) { 'mutation' }

      let(:expect_result) do
        <<-STRING
      mutation {
        product(id: 1) {
          id name
        }
      }
        STRING
      end

      it { is_expected.to eq(expect_result) }

      context 'with nested input attributes format' do
        let(:inputs) do
          { input: { attributes: { id: 1 } } }
        end
        let(:selected_fields) { [product: %i[id name]] }

        let(:expect_result) do
          <<-STRING
      mutation {
        product(input: {attributes: {id: 1}}) {
          product { id name }
        }
      }
          STRING
        end

    it { is_expected.to eq(expect_result) }

    context 'with empty conditions' do
      let(:conditions) { {} }
      let(:expect_result) { 'query { product { id name } }' }

      it { is_expected.to eq(expect_result) }
    end
  end
end
