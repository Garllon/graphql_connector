# frozen_string_literal: true

require 'spec_helper'

describe GraphqlConnector::Formatters::QueryFormat do
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
        query {
          product(id: 1) {
            id name
          }
        }
      STRING
    end

    it { is_expected.to eq(expect_result) }
  end
end
