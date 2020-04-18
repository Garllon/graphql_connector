# frozen_string_literal: true

require 'spec_helper'

describe GraphqlConnector::ServiceClassable::ClassMethodValidator do
  describe '.validate_class_method' do
    subject(:validate_class_method) do
      described_class.validate_class_method(class_method_name, Currency)
    end
    let(:class_method_name) { :all }
    let(:invoked_class) { class Currency; end }

    before do
      invoked_class
    end

    it { expect { validate_class_method }.to_not raise_error }

    context 'when invoked_class implements already the class method' do
      let(:invoked_class) do
        class Currency
          def self.all
            puts 'Implementation of all'
          end
        end
      end

      let(:class_method_already_implemented_error) do
        GraphqlConnector::ServiceClassable::ClassMethodAlreadyImplementedError
      end

      it 'raises an InvalidClassMethodError' do
        expect { validate_class_method }
          .to raise_error(class_method_already_implemented_error)
      end
    end

    after do
      Object.send :remove_const, 'Currency'
    end
  end

  describe '.validate_element_class_type' do
    subject(:validate_element_class_type) do
      described_class.validate_element_class_type(element, type)
    end
    let(:element) { 'id' }
    let(:type) { String }

    it { expect { validate_element_class_type }.to_not raise_error }

    context 'when type does not match with the elements class' do
      let(:type) { Symbol }
      let(:invalid_class_type_error) do
        GraphqlConnector::ServiceClassable::InvalidClassTypeError
      end

      it do
        expect { validate_element_class_type }
          .to raise_error(invalid_class_type_error)
      end
    end
  end
end
