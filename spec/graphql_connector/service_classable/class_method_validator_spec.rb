# frozen_string_literal: true

require 'spec_helper'

describe GraphqlConnector::ServiceClassable::ClassMethodValidator do
  describe '.validate' do
    subject(:validate) do
      described_class.validate(class_method_name, query_type)
    end
    let(:class_method_name) { :method }
    let(:query_type) { :query }

    it { expect { validate }.to_not raise_error }

    context 'with stringyfied arguments' do
      let(:class_method_name) { 'method' }
      let(:query_type) { 'query' }

      it { expect { validate }.to_not raise_error }
    end

    context 'with invalid class_method_name' do
      let(:class_method_name) { Class }
      let(:invalid_class_method_error) do
        GraphqlConnector::ServiceClassable::InvalidClassMethodError
      end

      it 'raises an InvalidClassMethodError' do
        expect { validate }.to raise_error(invalid_class_method_error)
      end
    end

    context 'with invalid query_type' do
      let(:query_type) { Class }
      let(:invalid_class_method_error) do
        GraphqlConnector::ServiceClassable::InvalidClassMethodError
      end

      it 'raises an InvalidClassMethodError' do
        expect { validate }.to raise_error(invalid_class_method_error)
      end
    end
  end
end
