# frozen_string_literal: true

require 'spec_helper'

describe GraphqlConnector::Formatters::MutationFormat do
  let(:format) do
    described_class.new(model, conditions, selected_fields)
  end
  let(:conditions) { { id: 1 } }
  let(:model) { 'product' }
  let(:selected_fields) { %w[id name] }

  describe '#create' do
    subject { format.create }

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
      let(:conditions) do
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
    end
  end
end
