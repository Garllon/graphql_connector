# frozen_string_literal: true

require 'spec_helper'

describe GraphqlConnector::ServiceClassable::ReturnFieldsValidator do
  describe '.validate' do
    subject(:validate) { described_class.validate(return_fields) }
    let(:return_fields) { [:id, :name, category: [:id], product: [:id]] }

    it { expect { validate }.to_not raise_error }

    context 'with invalid root format' do
      let(:return_fields) { { id: [:name] } }
    end

    context 'with invalid format of one entry' do
      let(:return_fields) { [:id, Class] }
      let(:return_fields_error) do
        GraphqlConnector::ServiceClassable::ReturnFieldsErrors
      end

      it 'raises an ReturnFieldsErrors' do
        expect { validate }.to raise_error(return_fields_error)
      end
    end

    context 'with invalid nested entry format' do
      let(:return_fields) { [:id, category: [Class]] }
      let(:return_fields_error) do
        GraphqlConnector::ServiceClassable::ReturnFieldsErrors
      end

      it 'raises an ReturnFieldsErrors' do
        expect { validate }.to raise_error(return_fields_error)
      end
    end

    context 'with invalid deep nested entry format' do
      let(:return_fields) { [:id, category: [foo: [Class]]] }
      let(:return_fields_error) do
        GraphqlConnector::ServiceClassable::ReturnFieldsErrors
      end

      it 'raises an ReturnFieldsErrors' do
        expect { validate }.to raise_error(return_fields_error)
      end
    end
  end
end
