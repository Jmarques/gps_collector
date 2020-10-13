# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'GPS Points management' do
  # We want to test the entire app stack, including middlewares.
  OUTER_APP = Rack::Builder.parse_file('config.ru').first

  def app
    OUTER_APP
  end

  shared_examples 'it return an error message' do
    let(:expected_error_message) {}

    it { expect(last_response.status).to eq 422 }
    it do
      expect(last_response.body).to eq(expected_error_message.to_json) unless expected_error_message.nil?
    end
  end

  describe '/ POST' do
    subject { post '/', params.to_json, { 'CONTENT_TYPE' => 'application/json' } }
    let(:params) { [] }

    before { subject }

    shared_examples 'it successfully creates points' do
      it { expect(last_response.status).to eq 201 }
      it { expect(last_response.body).to eq({ success: '2 point(s) created' }.to_json) }
    end

    context 'Given an array of points' do
      let(:params) do
        [
          {
            'type': 'Point',
            'coordinates': [1.0, 0.0]
          },
          {
            'type': 'Point',
            'coordinates': [0.0, 1.0]
          }
        ]
      end

      it_behaves_like('it successfully creates points')
    end

    context 'Given an array of geometry collections' do
      let(:params) do
        [
          {
            'type': 'Point',
            'coordinates': [1.0, 0.0]
          },
          {
            'type': 'GeometryCollection',
            'geometries': [
              {
                'type': 'Point',
                'coordinates': [2.0, -2.0]
              }
            ]
          }
        ]
      end

      it_behaves_like('it successfully creates points')
    end

    # Error management

    context 'Given an unsupported geometry' do
      let(:params) do
        [
          {
            'type': 'MultiPoints',
            'coordinates': [[1.0, 0.0], [0.0, 1.0]]
          }
        ]
      end

      it_behaves_like('it return an error message') do
        let(:expected_error_message) { { error: 'Unsuported Geometry `type` MultiPoints' } }
      end
    end

    context 'Given a incorrectly formated point' do
      let(:params) do
        [
          {
            'type': 'Point',
            'coordinate': [1.0, 0.0]
          }
        ]
      end

      it_behaves_like('it return an error message') do
        let(:expected_error_message) { { error: 'Unsuported coordinates' } }
      end
    end

    context 'Given a incorrectly formated collection' do
      let(:params) do
        [
          {
            'type': 'Point',
            'coordinates': [1.0, 0.0]
          },
          {
            'type': 'GeometryCollection',
            'geometries': {
              'type': 'Point',
              'coordinates': [2.0, -2.0]
            }
          }
        ]
      end

      it_behaves_like('it return an error message') do
        let(:expected_error_message) { { error: 'Expecting `geometries` to be Array' } }
      end
    end
  end

  describe '/ GET' do
    subject { post '/', params.to_json, header }
    let(:params) { [] }
    let(:header) { { 'HTTP_X_HTTP_METHOD_OVERRIDE' => 'GET', 'CONTENT_TYPE' => 'application/json' } }

    before { subject }

    shared_examples 'it successfully return points' do
      it { expect(last_response.status).to eq 200 }
      it { expect(JSON.parse(last_response.body)).to be_a(Array) }
    end

    context 'Given a point and a radius' do
      let(:params) do
        {
          'geometry': {
            'type': 'Point',
            'coordinates': [1.0, 1.0]
          },
          'radius': {
            'length': 2000
          }
        }
      end

      it_behaves_like 'it successfully return points'

      context 'Given a radius in foot' do
        let(:params) do
          {
            'geometry': {
              'type': 'Point',
              'coordinates': [1.0, 1.0]
            },
            'radius': {
              'length': 2000,
              'unit': 'foot'
            }
          }
        end

        it_behaves_like 'it successfully return points'
      end

      context 'Given a radius in cm' do
        let(:params) do
          {
            'geometry': {
              'type': 'Point',
              'coordinates': [1.0, 1.0]
            },
            'radius': {
              'length': 2000,
              'unit': 'cm'
            }
          }
        end

        it_behaves_like('it return an error message') do
          let(:expected_error_message) { { error: 'Unknown unit `cm`, please use meter, foot' } }
        end
      end
    end

    context 'Given a polygon' do
      let(:params) do
        {
          'geometry': {
            'type': 'Polygon',
            'coordinates': [
              [2.0, 2.0],
              [2.0, -2.0],
              [-2.0, 2.0],
              [-2.0, -2.0],
              [2.0, 2.0]
            ]
          }
        }
      end

      it_behaves_like 'it successfully return points'
    end
  end
end
