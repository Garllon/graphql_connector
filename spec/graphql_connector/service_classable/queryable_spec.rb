# frozen_string_literal: true

require 'spec_helper'

describe GraphqlConnector::ServiceClassable::Queryable do
  let(:object) do
    class Currency
      extend GraphqlConnector::ServiceClassable::Queryable
    end
  end

  before do
    object
  end

  after do
    Object.send :remove_const, object.to_s
  end

  describe '.add_query' do
    subject(:add_query) do
      object.add_query(by_id: graphql_type,
                       params: params,
                       returns: return_fields)
    end
    let(:graphql_type) { :products }
    let(:params) { [:id] }
    let(:return_fields) { [:id, :name, catgeory: [:id]] }

    it 'validates return fields' do
      expect(GraphqlConnector::ServiceClassable::ReturnFieldsValidator)
        .to receive(:validate).with(return_fields)

      add_query
    end

    it 'validates class method on object' do
      expect(GraphqlConnector::ServiceClassable::ClassMethodValidator)
        .to receive(:validate_class_method).with(:by_id, object)

      add_query
    end

    it 'validates query type' do
      expect(GraphqlConnector::ServiceClassable::ClassMethodValidator)
        .to receive(:validate_element_class_type).with(graphql_type, Symbol)

      add_query
    end

    it 'validates params' do
      expect(GraphqlConnector::ServiceClassable::ParamsValidator)
        .to receive(:validate).with(params)

      add_query
    end

    it 'creates a class method by_id(id:) on object' do
      add_query

      expect(object).to respond_to(:by_id).with_keywords(:id)
    end

    context 'without params' do
      let(:params) { [] }

      it 'does not validate params' do
        expect(GraphqlConnector::ServiceClassable::ParamsValidator)
          .not_to receive(:validate)

        add_query
      end

      it 'creates a class method by_id on object' do
        add_query

        expect(object).to respond_to(:by_id)
      end
    end
  end

  describe '.add_raw_query' do
    subject(:add_raw_query) do
      object.add_raw_query(by_id: raw_graphql_query, params: params)
    end
    let(:params) { [:id] }
    let(:raw_graphql_query) { 'query { currency { id } }' }

    it 'validates class method on object' do
      expect(GraphqlConnector::ServiceClassable::ClassMethodValidator)
        .to receive(:validate_class_method).with(:by_id, object)

      add_raw_query
    end

    it 'validates query type' do
      expect(GraphqlConnector::ServiceClassable::ClassMethodValidator)
        .to receive(:validate_element_class_type)
        .with(raw_graphql_query, String)

      add_raw_query
    end

    it 'validates params' do
      expect(GraphqlConnector::ServiceClassable::ParamsValidator)
        .to receive(:validate).with(params)

      add_raw_query
    end

    it 'creates a class method by_id(id:) on object' do
      add_raw_query

      expect(object).to respond_to(:by_id).with_keywords(:id)
    end

    context 'without params' do
      let(:params) { [] }

      it 'does not validate params' do
        expect(GraphqlConnector::ServiceClassable::ParamsValidator)
          .not_to receive(:validate)

        add_raw_query
      end

      it 'creates a class method by_id on object' do
        add_raw_query

        expect(object).to respond_to(:by_id)
      end
    end
  end
end
