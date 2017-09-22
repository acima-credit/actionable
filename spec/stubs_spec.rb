require 'spec_helper'

module Actionable
  describe Action do
    let(:base_fixtures) { { a: 1, b: 2 } }
    context '#mock_success' do
      let(:klass) { Success }
      subject { described_class.mock_success fixtures }
      context 'with default message' do
        let(:fixtures) { base_fixtures }
        it { expect(subject).to be_a klass }
        it { expect(subject.code).to eq :success }
        it { expect(subject.message).to eq Action::DEFAULT_SUCCESS_MESSAGE }
        it { expect(subject.errors).to eq({}) }
        it { expect(subject.fixtures).to eq fixtures.stringify_keys }
        it { is_expected.to be_success }
        it { is_expected.to_not be_failure }
      end
      context 'with specific message' do
        let(:fixtures) { base_fixtures.update message: 'OK!' }
        it { expect(subject).to be_a klass }
        it { expect(subject.code).to eq :success }
        it { expect(subject.message).to eq 'OK!' }
        it { expect(subject.errors).to eq({}) }
        it { expect(subject.fixtures).to eq('a' => 1, 'b' => 2) }
        it { is_expected.to be_success }
        it { is_expected.to_not be_failure }
      end
    end
    context '#mock_failure' do
      let(:klass) { Failure }
      let(:code) { :error }
      let(:message) { 'Oh oh!' }
      subject { described_class.mock_failure code, message, fixtures }
      context 'with default errors' do
        let(:fixtures) { base_fixtures }
        it { expect(subject).to be_a klass }
        it { expect(subject.code).to eq code }
        it { expect(subject.message).to eq message }
        it { expect(subject.errors).to eq({}) }
        it { expect(subject.formatted_errors).to eq '' }
        it { expect(subject.fixtures).to eq('a' => 1, 'b' => 2) }
        it { is_expected.to_not be_success }
        it { is_expected.to be_failure }
      end
      context 'with specific errors' do
        let(:fixtures) { base_fixtures.update errors: { c: 1 } }
        it { expect(subject).to be_a klass }
        it { expect(subject.code).to eq code }
        it { expect(subject.message).to eq message }
        it { expect(subject.errors).to eq('c' => 1) }
        it { expect(subject.formatted_errors).to eq '{"c"=>1}' }
        it { expect(subject.fixtures).to eq('a' => 1, 'b' => 2) }
        it { is_expected.to_not be_success }
        it { is_expected.to be_failure }
      end
    end
  end
end
