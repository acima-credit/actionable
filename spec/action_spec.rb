require 'spec_helper'

module Actionable
  describe Action do
    let(:klass) { TestActionable::GreatAction }
    context 'class' do
      it { expect(klass.model).to eq Invoice }
      it { expect(klass.actions.to_a).to eq %i{ fail_for_2 add_one add_two } }
      it { expect(klass.method(:call)).to eq klass.method(:run) }
    end
    context 'result' do
      subject { klass.run number }
      context 'success' do
        let(:number) { 10 }
        it { is_expected.to be_a Actionable::Success }
        it { expect(subject.code).to eq :success }
        it { expect(subject.message).to eq 'Completed successfully.' }
        it { expect(subject.fixtures).to eq('number' => 13) }
        it { msg = nil; klass.run(number) { |x| msg = x.message }; expect(msg).to eq 'Completed successfully.' }
      end
      context 'failure' do
        let(:number) { 2 }
        it { is_expected.to be_a Actionable::Failure }
        it { expect(subject.code).to eq :bad_number }
        it { expect(subject.message).to eq 'Wrong number' }
        it { expect(subject.fixtures).to eq('number' => 2) }
        it { msg = nil; klass.run(number) { |x| msg = x.message }; expect(msg).to be_nil }
      end
    end
  end
end
