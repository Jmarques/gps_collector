# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Repository::PointRepository do
  describe '.within_radius' do
    subject { described_class.within_radius(arguments) }
    let(:arguments) { { latitude: 0.0, longitude: 0.0 } }

    it { is_expected.to be_a(Sequel::Postgres::Dataset) }
  end

  describe '.within_polygon' do
    subject { described_class.within_polygon(arguments) }
    let(:arguments) { [[2, 2], [2, -2], [-2, -2], [-2, 2], [2, 2]] }

    it { is_expected.to be_a(Sequel::Postgres::Dataset) }
  end
end
