# frozen_string_literal: true

require 'spec_helper'

describe 'various service class inclusion cases' do
  let!(:car) do
    class Car
      extend GraphqlConnector::ServiceClassable::Queryable

      add_query all_cars: :cars_all, returns: %i[id name]
      add_query by_id_name: :cars_by_params,
                params: %i[id name],
                returns: %i[id name]
      add_raw_query raw: 'query { cars { id, name } }'
      add_raw_query raw_by_id_name: 'query cars($id: !ID, $name: !String) '\
                                    '{ cars(id: $id, name: $name) }',
                    params: %i[id name]
      add_mutation create: :create_car,
                   params: %i[name type],
                   returns: %i[id name]
    end
  end
  let(:car_client) do
    instance_double(GraphqlConnector::HttpClient,
                    raw_query: raw_response_car,
                    query: open_struct_response_car,
                    mutation: open_struct_response_car)
  end
  let(:raw_response_car) { [{ id: '1', name: 'Audi' }] }
  let(:open_struct_response_car) do
    raw_response_car.map { |entry| OpenStruct.new(entry) }
  end

  before do
    allow(Car).to receive(:http_client) { car_client }
  end

  after do
    Object.send :remove_const, 'Car'
  end

  it 'creates for each add method a class method ' do
    expect(Car.methods).to include(:all_cars, :by_id_name, :raw, :raw_by_id_name, :create)
  end

  describe '.all_cars' do
    subject(:all_cars) { Car.all_cars }

    it 'forwards params to http_client' do
      expect(car_client)
        .to receive(:query).with(:cars_all, {}, %i[id name], httparty_adapter_options: {})

      all_cars
    end

    it { is_expected.to eq(open_struct_response_car) }
  end

  describe '.by_id_name' do
    subject(:by_id_name) { Car.by_id_name(id: '1', name: 'Audi') }

    it 'forwards params to http_client' do
      expect(car_client)
        .to receive(:query)
        .with('cars_by_params',
              { id: '1', name: 'Audi' },
              %i[id name],
              httparty_adapter_options: {})

      by_id_name
    end

    it { is_expected.to eq(open_struct_response_car) }
  end

  describe '.raw' do
    subject(:raw) { Car.raw }

    it 'forwards params to http_client' do
      expect(car_client)
        .to receive(:raw_query).with('query { cars { id, name } }', httparty_adapter_options: {})

      raw
    end

    it { is_expected.to eq(raw_response_car) }
  end

  describe '.raw_by_id_name' do
    subject(:raw) { Car.raw_by_id_name(id: '1', name: 'Audi') }

    it 'forwards params to http_client' do
      expect(car_client)
        .to receive(:raw_query)
        .with('query cars($id: !ID, $name: !String) { cars(id: $id, name: $name) }',
              variables: { id: '1', name: 'Audi' },
              httparty_adapter_options: {})

      raw
    end

    it { is_expected.to eq(raw_response_car) }
  end

  describe '.create' do
    subject(:create) { Car.create(name: 'Audi', type: 'Koachn') }

    it 'forwards params to http_client' do
      expect(car_client)
        .to receive(:mutation)
        .with('create_car',
              { name: 'Audi', type: 'Koachn' },
              %i[id name],
              httparty_adapter_options: {})

      create
    end

    it { is_expected.to eq(open_struct_response_car) }
  end

  context 'with another service class' do
    let!(:truck) do
      class Truck
        extend GraphqlConnector::ServiceClassable::Queryable

        add_query all_trucks: :trucks_all, returns: [:truck_id, brand: :name]
      end
    end
    let(:truck_client) do
      instance_double(GraphqlConnector::HttpClient, raw_query: [], query: [])
    end

    before do
      allow(Truck).to receive(:http_client) { truck_client }
    end

    after do
      Object.send :remove_const, 'Truck'
    end

    it 'creates for each query a class method ' do
      expect(Truck.methods).to include(:all_trucks)
    end

    describe '.all_trucks' do
      subject(:all_trucks) { Truck.all_trucks }

      it 'forwards params to http_client' do
        expect(truck_client)
          .to receive(:query)
          .with(:trucks_all, {}, [:truck_id, brand: :name], httparty_adapter_options: {})

        all_trucks
      end

      it { is_expected.to eq([]) }
    end
  end

  context 'with invalid graphql query type' do
    let(:camper) do
      class Camper2
        extend GraphqlConnector::ServiceClassable::Queryable

        add_query all: Class, returns: [:id]
      end
    end
    let(:invalid_class_type_error) do
      GraphqlConnector::ServiceClassable::InvalidClassTypeError
    end

    it 'raises an InvalidClassTypeError' do
      expect { camper }.to raise_error(invalid_class_type_error)
    end
  end

  context 'with invalid params' do
    let(:camper) do
      class Camper3
        extend GraphqlConnector::ServiceClassable::Queryable

        add_query all: :all_campers, params: [Class], returns: [:id]
      end
    end

    it 'raises an InvalidParamsError' do
      expect { camper }
        .to raise_error(GraphqlConnector::ServiceClassable::InvalidParamsError)
    end
  end

  context 'with httparty_adapter_options set' do
    let!(:car) do
      class Car
        extend GraphqlConnector::ServiceClassable::Queryable

        add_query all_cars: :cars,
                  params: %i[id],
                  returns: %i[name],
                  httparty_adapter_options: { timeout: 3 }
        add_raw_query all: 'query { cars { id, name } }',
                      httparty_adapter_options: { timeout: 3, validate: false }
        add_mutation create: :create_car,
                     params: %i[name],
                     returns: %i[id],
                     httparty_adapter_options: { validate: true }
      end
    end

    it 'forwards httparty_adapter_options used in add_query to http_client' do
      expect(car_client)
        .to receive(:query)
        .with(anything, anything, anything, httparty_adapter_options: { timeout: 3 })

      Car.all_cars(id: [1])
    end

    it 'forwards httparty_adapter_options used in add_raw_query to http_client' do
      expect(car_client)
        .to receive(:raw_query)
        .with(anything, httparty_adapter_options: { timeout: 3, validate: false })

      Car.all
    end

    it 'forwards httparty_adapter_options used in add_mutation to http_client' do
      expect(car_client)
        .to receive(:mutation)
        .with(anything,
              anything,
              anything,
              httparty_adapter_options: { validate: true })

      Car.create(name: 'Audi')
    end
  end
end
