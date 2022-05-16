# frozen_string_literal: true

require 'spec_helper'

describe GraphqlConnector::Formatters::QueryFormat do
  let(:format) do
    described_class.new(model, conditions, selected_fields)
  end
  let(:conditions) { { id: 1, brand_name: 'foo', foo_bar: { bar_id: 3 } } }
  let(:model) { 'salable_product' }
  let(:selected_fields) { [:id, :name, :selling_price, bar_foo: %i[foo_bar barFoo]] }

  describe '#create' do
    subject { format.create }

    let(:expect_result) do
      <<-STRING
        query {
          salableProduct(id: 1, brandName: "foo", fooBar: {barId: 3}) {
            id name sellingPrice barFoo { fooBar barFoo }
          }
        }
      STRING
    end

    it { is_expected.to eq(expect_result) }
  end
end
