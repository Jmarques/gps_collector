# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Helper::RGeoDecoder do
  describe '.to_sql' do
    subject { described_class.to_sql(attributes) }
    let(:attributes) {}

    context 'providing valides attributes' do
      let(:attributes) { { 'type' => 'Points', 'coordinates' => [100.0, 0.0] } }

      it { is_expected.to eq('POINT(100.0 0.0)') }
    end

    context 'providing invalides attributes' do
      let(:attributes) { { 'type' => 'Points', 'coordinates' => ['1f0', 0.0] } }

      it { expect { subject }.to raise_error(ArgumentError) }
    end
  end
end
