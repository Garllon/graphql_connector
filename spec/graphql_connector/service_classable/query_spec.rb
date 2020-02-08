# frozen_string_literal: true

require 'spec_helper'

describe GraphqlConnector::ServiceClassable::Query do
  let!(:car) do
    class Car
      include GraphqlConnector::ServiceClassable::Query

      return_fields :id, :name

      query all_cars: :cars_all
      query by_id_name: :cars_by_params, params: %i[id name]
      query raw: 'query { cars { id, name } }'
      query raw_by_id_name: 'query { cars($id: !ID, $name: !String) '\
                            '{ cars(id: $id, name: $name) } }',
            params: %i[id name]
    end
  end
  let(:car_client) do
    instance_double(GraphqlConnector::HttpClient,
                    raw_query: raw_response_car,
                    query: open_struct_response_car)
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

  it 'creates for each query a class method ' do
    expect(Car.methods)
      .to include(:all_cars, :by_id_name, :raw, :raw_by_id_name)
  end

  describe '.all_cars' do
    subject(:all_cars) { Car.all_cars }

    it 'forwards params to http_client' do
      expect(car_client).to receive(:query).with(:cars_all, {}, %i[id name])

      all_cars
    end

    it { is_expected.to eq(open_struct_response_car) }
  end

  describe '.by_id_name' do
    subject(:by_id_name) { Car.by_id_name(id: '1', name: 'Audi') }

    it 'forwards params to http_client' do
      expect(car_client)
        .to receive(:query)
        .with('cars_by_params', { id: '1', name: 'Audi' }, %i[id name])

      by_id_name
    end

    it { is_expected.to eq(open_struct_response_car) }
  end

  describe '.raw' do
    subject(:raw) { Car.raw }

    it 'forwards params to http_client' do
      expect(car_client)
        .to receive(:raw_query).with('query { cars { id, name } }')

      raw
    end

    it { is_expected.to eq(raw_response_car) }
  end

  describe '.raw_by_id_name' do
    subject(:raw) { Car.raw_by_id_name(id: '1', name: 'Audi') }

    it 'forwards params to http_client' do
      expect(car_client)
        .to receive(:raw_query)
        .with('query { cars($id: !ID, $name: !String) '\
              '{ cars(id: $id, name: $name) } }',
              variables: { id: '1', name: 'Audi' })

      raw
    end

    it { is_expected.to eq(raw_response_car) }
  end

  context 'with another service class' do
    let!(:truck) do
      class Truck
        include GraphqlConnector::ServiceClassable::Query

        return_fields :truck_id
        return_fields [brand: :name]

        query all_trucks: :trucks_all
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
          .with(:trucks_all, {}, [:truck_id, [{ brand: :name }]])

        all_trucks
      end

      it { is_expected.to eq([]) }
    end
  end

  context 'when undefined return_fields' do
    let(:camper) do
      class Camper1
        include GraphqlConnector::ServiceClassable::Query

        query all: :camper_all
      end
    end

    it 'raises an ReturnFieldsErrors' do
      expect { camper }
        .to raise_error(GraphqlConnector::ServiceClassable::ReturnFieldsErrors)
    end
  end

  context 'with invalid type_mapping' do
    let(:camper) do
      class Camper2
        include GraphqlConnector::ServiceClassable::Query

        return_fields :id
        query all: Class
      end
    end
    let(:type_mapping_error) do
      GraphqlConnector::ServiceClassable::InvalidTypeMappingError
    end

    it 'raises an InvalidTypeMappingError' do
      expect { camper }.to raise_error(type_mapping_error)
    end
  end

  context 'with invalid params' do
    let(:camper) do
      class Camper3
        include GraphqlConnector::ServiceClassable::Query

        return_fields :id
        query all: :all_campers, params: [Class]
      end
    end

    it 'raises an InvalidParamsErrors' do
      expect { camper }
        .to raise_error(GraphqlConnector::ServiceClassable::InvalidParamsErrors)
    end
  end
end