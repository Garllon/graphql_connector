# frozen_string_literal: true

require 'spec_helper'

shared_examples 'runs common validations' do
  it 'validates class method on object' do
    expect(GraphqlConnector::ServiceClassable::ClassMethodValidator)
      .to receive(:validate_class_method).with(:by_id, object)

    subject
  end

  it 'validates params' do
    expect(GraphqlConnector::ServiceClassable::ParamsValidator)
      .to receive(:validate).with(params)

    subject
  end
end

shared_examples 'runs return_fields validation' do
  it 'validates return fields' do
    expect(GraphqlConnector::ServiceClassable::ReturnFieldsValidator)
      .to receive(:validate).with(return_fields)

    subject
  end
end

shared_examples 'runs Symbol query_type validation' do
  it 'validates query type' do
    expect(GraphqlConnector::ServiceClassable::ClassMethodValidator)
      .to receive(:validate_element_class_type).with(graphql_type, Symbol)

    subject
  end
end

shared_examples 'common class method creation' do
  it 'creates a class method by_id(id:) on object' do
    subject

    expect(object).to respond_to(:by_id).with_keywords(:id)
  end

  context 'without params' do
    let(:params) { [] }

    it 'does not validate params' do
      expect(GraphqlConnector::ServiceClassable::ParamsValidator)
        .not_to receive(:validate)

      subject
    end

    it 'creates a class method by_id on object' do
      subject

      expect(object).to respond_to(:by_id)
    end
  end
end

describe GraphqlConnector::ServiceClassable::Queryable do
  let(:object) do
    class Currency
      extend GraphqlConnector::ServiceClassable::Queryable
    end
  end
  let(:httparty_adapter_options) { { timeout: 3 } }

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
                       returns: return_fields,
                       httparty_adapter_options: httparty_adapter_options)
    end
    let(:graphql_type) { :products }
    let(:params) { [:id] }
    let(:return_fields) { [:id, :name, catgeory: [:id]] }

    it_behaves_like 'runs return_fields validation'

    it_behaves_like 'runs common validations'

    it_behaves_like 'runs Symbol query_type validation'

    it_behaves_like 'common class method creation'
  end

  describe '.add_raw_query' do
    subject(:add_raw_query) do
      object.add_raw_query(by_id: raw_graphql_query,
                           params: params, httparty_adapter_options: httparty_adapter_options)
    end
    let(:params) { [:id] }
    let(:raw_graphql_query) { 'query { currency { id } }' }

    it_behaves_like 'runs common validations'

    it 'validates query type' do
      expect(GraphqlConnector::ServiceClassable::ClassMethodValidator)
        .to receive(:validate_element_class_type)
        .with(raw_graphql_query, String)

      add_raw_query
    end

    it_behaves_like 'common class method creation'
  end

  describe '.add_mutation' do
    subject(:add_mutation) do
      object.add_mutation(by_id: graphql_type,
                          params: params,
                          returns: return_fields,
                          httparty_adapter_options: httparty_adapter_options)
    end
    let(:graphql_type) { :products }
    let(:params) { [:id] }
    let(:return_fields) { [:id, :name, catgeory: [:id]] }

    it_behaves_like 'runs return_fields validation'

    it_behaves_like 'runs common validations'

    it_behaves_like 'runs Symbol query_type validation'

    it_behaves_like 'common class method creation'
  end
end
