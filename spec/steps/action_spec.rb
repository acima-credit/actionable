# frozen_string_literal: true

require 'spec_helper'

module Actionable
  class Steps
    describe Action do
      let(:klass) { TestActionable::SmallAction }
      let(:options) { { params: %i[number] } }
      subject { described_class.new klass, options }
      it('name   ') { expect(subject.name).to eq 'test_actionable/small_action' }
      it('options') { expect(subject.options).to eq options }
      it('klass  ') { expect(subject.klass).to eq klass }
      context '#run' do
        let(:instance) { TestActionable::GreatAction.new number }
        context 'on success' do
          let(:number) { 9 }
          it('run') do
            subject.run instance
            expect(instance.fixtures[:number]).to eq(number + 3)
            expect(instance.finished?).to eq false
          end
        end
        context 'on failure' do
          let(:number) { 6 }
          it('run') do
            subject.run instance
            expect(instance.fixtures[:number]).to eq number
            expect(instance.finished?).to eq true
            expect(instance.result.failure?).to eq true
          end
        end
      end
    end
  end
end
