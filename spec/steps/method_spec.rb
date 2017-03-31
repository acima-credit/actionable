require 'spec_helper'

module Actionable
  class Steps
    describe Method do
      let(:name) { 'add_one' }
      let(:options) { {} }
      subject { described_class.new name, options }
      it('name   ') { expect(subject.name).to eq 'add_one' }
      it('options') { expect(subject.options).to eq options }
      context '#run' do
        let(:instance) { TestActionable::GreatAction.new 9 }
        it('run') do
          expect(instance).to receive(name)
          subject.run instance
        end
      end
    end
  end
end
