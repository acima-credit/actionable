require 'spec_helper'

module Actionable
  describe Success, actionable: true do
    context 'default' do
      subject { described_class.new }
      it { is_expected.to be_a described_class }
      it { expect(subject.code).to eq :success }
      it { expect(subject.message).to eq '' }
      it { expect(subject.errors).to be_nil }
      it { expect(subject.fixtures).to eq({}) }
      it { is_expected.to be_success }
      it { is_expected.to_not be_failure }
    end
    context 'custom' do
      let(:code) { :success }
      let(:message) { 'some message' }
      let(:errors) { { a: 1 } }
      let(:fixtures) { { b: 1 } }
      subject { described_class.new code: code, message: message, errors: errors, fixtures: fixtures }
      it { is_expected.to be_a described_class }
      it { expect(subject.code).to eq code }
      it { expect(subject.message).to eq message }
      it { expect(subject.errors).to eq errors.with_indifferent_access }
      it { expect(subject.fixtures).to eq fixtures.with_indifferent_access }
      it { is_expected.to be_success }
      it { is_expected.to_not be_failure }
    end
  end
end