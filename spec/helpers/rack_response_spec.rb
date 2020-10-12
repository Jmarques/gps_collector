# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Helper::RackResponse do
  describe '.respond_with' do
    subject { described_class.respond_with(*arguments) }
    let(:arguments) {}

    context 'providing 200 http code' do
      let(:arguments) { 200 }

      it { is_expected.to eq([200, { 'Content-Type' => 'application/json' }, [{ success: :ok }.to_json]]) }
    end

    context 'providing 404 http code' do
      let(:arguments) { 404 }

      it do
        is_expected.to eq(
          [404, { 'Content-Type' => 'application/json' }, [{ error: 'Endpoint not supported' }.to_json]]
        )
      end
    end

    context 'providing a custom message' do
      let(:arguments) { [402, { message: { error: 'specs' } }] }

      it { is_expected.to eq([402, { 'Content-Type' => 'application/json' }, [{ error: 'specs' }.to_json]]) }
    end
  end
end
