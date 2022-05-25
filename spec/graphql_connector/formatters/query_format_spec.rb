# frozen_string_literal: true

require 'spec_helper'

describe GraphqlConnector::Formatters::QueryFormat do
  let(:format) do
    described_class.new(model, conditions, selected_fields, camelize_query_names)
  end
  let(:conditions) { { id: 1, brand_name: 'foo', foo_bar: { bar_id: 3 } } }
  let(:model) { 'salable_product' }
  let(:selected_fields) { [:id, :name, :selling_price, bar_foo: %i[foo_bar barFoo]] }
  let(:camelize_query_names) { true }

  describe '#create' do
    subject { format.create }

    let(:expected_result) do
      <<-STRING
        query {
          salableProduct(id: 1, brandName: "foo", fooBar: {barId: 3}) {
            id name sellingPrice barFoo { fooBar barFoo }
          }
        }
      STRING
    end

    it { is_expected.to eq(expected_result) }

    context 'with camelization of query names disabled' do
      let(:camelize_query_names) { false }
      let(:expected_result) do
        <<-STRING
        query {
          salable_product(id: 1, brand_name: "foo", foo_bar: {bar_id: 3}) {
            id name selling_price bar_foo { foo_bar barFoo }
          }
        }
        STRING
      end

      it { is_expected.to eq(expected_result) }
    end
  end
end
