# frozen_string_literal: true

require 'spec_helper'

describe GraphqlConnector::ServiceClassable::ParamsValidator do
  describe '.validate' do
    subject(:validate) { described_class.validate(query_params) }
    let(:query_params) { %i[id name] }

    it { expect { validate }.to_not raise_error }

    context 'with empty params' do
      let(:query_params) { [] }

      it { expect { validate }.to_not raise_error }
    end

    context 'with stringyfied params' do
      let(:query_params) { %w[id name] }

      it { expect { validate }.to_not raise_error }
    end

    context 'with invalid params' do
      let(:query_params) { [Class] }
      let(:invalid_params_error) do
        GraphqlConnector::ServiceClassable::InvalidParamsError
      end

      it 'raises an InvalidParamsError' do
        expect { validate }.to raise_error(invalid_params_error)
      end
    end
  end
end
