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

      describe 'equality' do
        context 'unmatched names' do
          let(:method_one) { described_class.new 'one' }
          let(:method_two) { described_class.new 'two' }

          it 'should not be equal' do
            expect(method_one).to_not eq method_two
          end

          it 'should not collide in a Set' do
            expect(Set.new([method_one, method_two]).length).to eq 2
          end
        end

        context 'unmatched classes' do
          let(:method_one) { described_class.new 'one' }
          let(:method_two) { Actionable::Steps::Case.new('one', {}) {} }

          it 'should not be equal' do
            expect(method_one).to_not eq method_two
          end

          it 'should not collide in a Set' do
            expect(Set.new([method_one, method_two]).length).to eq 2
          end
        end

        context 'matching class and name' do
          let(:method_one) { described_class.new 'one' }
          let(:method_two) { described_class.new 'one' }

          it 'should be equal' do
            expect(method_one).to eq method_two
          end

          it 'should collide in a Set' do
            expect(Set.new([method_one, method_two]).length).to eq 1
          end
        end
      end
    end
  end
end
