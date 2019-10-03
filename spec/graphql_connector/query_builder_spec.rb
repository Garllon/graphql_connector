# frozen_string_literal: true

require 'spec_helper'

module GraphqlConnector
  describe QueryBuilder do
    let(:builder) { described_class.new(model, conditions, selected_fields) }
    let(:model) { 'product' }
    let(:conditions) { { id: 1 } }
    let(:selected_fields) { %w[id name] }
    subject { builder.create }

    let(:expect_result) { 'query { product(id: 1) { id name } }' }

    it 'returns a valid graphql query string' do
      subject.equal? expect_result
    end
  end
end
