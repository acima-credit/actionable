require 'spec_helper'

module Actionable
  describe Steps do
    context '.build' do
      let(:options) { {} }
      before { expect(klass).to receive(:new) }
      context 'string' do
        let(:klass) { Steps::Method }
        let(:name) { 'hello' }
        it { described_class.build name, options }
      end
      context 'symbol' do
        let(:klass) { Steps::Method }
        let(:name) { :hello }
        it { described_class.build name, options }
      end
      context 'action' do
        let(:klass) { Steps::Action }
        let(:name) { TestActionable::SmallAction }
        it { described_class.build name, options }
      end
    end
  end
end
