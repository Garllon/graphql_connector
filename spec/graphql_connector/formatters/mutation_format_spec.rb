# frozen_string_literal: true

require 'spec_helper'

describe GraphqlConnector::Formatters::MutationFormat do
  let(:format) do
    described_class.new(model, conditions, selected_fields, camelize_query_names)
  end
  let(:conditions) { { id: 1, brand_name: 'foo' } }
  let(:model) { 'salable_product' }
  let(:selected_fields) { %w[id name selling_price] }
  let(:camelize_query_names) { true }

  describe '#create' do
    subject { format.create }

    let(:expected_result) do
      <<-STRING
        mutation {
          salableProduct(id: 1, brandName: "foo") {
            id name sellingPrice
          }
        }
      STRING
    end

    it { is_expected.to eq(expected_result) }

    context 'with camelization of query names disabled' do
      let(:camelize_query_names) { false }
      let(:expected_result) do
        <<-STRING
        mutation {
          salable_product(id: 1, brand_name: "foo") {
            id name selling_price
          }
        }
        STRING
      end

      it { is_expected.to eq(expected_result) }
    end

    context 'with nested input attributes format' do
      let(:conditions) do
        { input: { attributes: { id: 1 } } }
      end
      let(:selected_fields) { [product: %i[id name]] }

      let(:expected_result) do
        <<-STRING
        mutation {
          salableProduct(input: {attributes: {id: 1}}) {
            product { id name }
          }
        }
        STRING
      end

      it { is_expected.to eq(expected_result) }
    end
  end
end
