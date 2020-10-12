# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'GPS Points management' do
  describe '/ POST' do
    subject { post '/', params.to_json, { 'CONTENT_TYPE' => 'application/json' } }
    let(:params) { [] }
    let(:app) { GpsCollector.new }

    before { subject }

    shared_examples 'it successfully creates points' do
      it { expect(last_response.status).to eq 201 }
      it { expect(last_response.body).to eq({ success: '2 point(s) created' }.to_json) }
    end

    shared_examples 'it return an error message' do
      let(:expected_error_message) {}

      it { expect(last_response.status).to eq 422 }
      it do
        expect(last_response.body).to eq(expected_error_message.to_json) unless expected_error_message.nil?
      end
    end

    context 'Given an array of points' do
      let(:params) do
        [
          {
            'type': 'Point',
            'coordinates': [100.0, 0.0]
          },
          {
            'type': 'Point',
            'coordinates': [0.0, 100.0]
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
            'coordinates': [100.0, 0.0]
          },
          {
            'type': 'GeometryCollection',
            'geometries': [
              {
                'type': 'Point',
                'coordinates': [200.0, -200.0]
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
            'coordinates': [[100.0, 0.0], [0.0, 100.0]]
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
            'coordinate': [100.0, 0.0]
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
            'coordinates': [100.0, 0.0]
          },
          {
            'type': 'GeometryCollection',
            'geometries': {
              'type': 'Point',
              'coordinates': [200.0, -200.0]
            }
          }
        ]
      end

      it_behaves_like('it return an error message') do
        let(:expected_error_message) { { error: 'Expecting `geometries` to be Array' } }
      end
    end
  end
end
