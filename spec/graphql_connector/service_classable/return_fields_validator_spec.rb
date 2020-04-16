# frozen_string_literal: true

require 'spec_helper'

describe GraphqlConnector::ServiceClassable::ReturnFieldsValidator do
  describe '.validate' do
    subject(:validate) { described_class.validate(return_fields) }
    let(:return_fields) { %i[id name] }

    it { expect { validate }.to_not raise_error }

    context 'with undefined return_fields' do
      let(:return_fields) {}
      let(:return_fields_error) do
        GraphqlConnector::ServiceClassable::ReturnFieldsErrors
      end

      it 'raises an ReturnFieldsErrors' do
        expect { validate }.to raise_error(return_fields_error)
      end
    end

    context 'with empty return fields' do
      let(:return_fields) { [] }
      let(:return_fields_error) do
        GraphqlConnector::ServiceClassable::ReturnFieldsErrors
      end

      it 'raises an ReturnFieldsErrors' do
        expect { validate }.to raise_error(return_fields_error)
      end
    end
  end
end
