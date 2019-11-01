# frozen_string_literal: true

require 'spec_helper'

module Actionable
  class Steps
    describe Case do
      let(:name) { :number }
      let(:options) { {} }
      subject do
        described_class.new(name, options) do
          on 1, :add_one
          on(/2/, TestActionable::AddTwo, params: [:number])
          on [3, 4], :add_five
          default :add_ten
        end
      end
      it('name   ') { expect(subject.name).to eq 'number' }
      it('options') { expect(subject.options).to eq options }
      context '#run' do
        let(:instance) { TestActionable::GreatAction.new number }
        context 'with a default' do
          context 'on regexp case' do
            let(:number) { 2 }
            it('run') do
              subject.run instance
              expect(instance.fixtures[:number]).to eq(number + 2)
              expect(instance.finished?).to eq false
            end
          end
          context 'on array case' do
            let(:number) { 3 }
            it('run') do
              subject.run instance
              expect(instance.fixtures[:number]).to eq(number + 5)
              expect(instance.finished?).to eq false
            end
          end
          context 'on other case' do
            let(:number) { 1 }
            it('run') do
              subject.run instance
              expect(instance.fixtures[:number]).to eq(number + 1)
              expect(instance.finished?).to eq false
            end
          end
          context 'on default case' do
            let(:number) { 9 }
            it('run') do
              subject.run instance
              expect(instance.fixtures[:number]).to eq(number + 10)
              expect(instance.finished?).to eq false
            end
          end
        end
        context 'without a default' do
          subject do
            described_class.new(name, options) do
              on 1, :add_one
            end
          end
          context 'on first case' do
            let(:number) { 1 }
            it('run') do
              subject.run instance
              expect(instance.fixtures[:number]).to eq(number + 1)
              expect(instance.finished?).to eq false
            end
          end
          context 'on default case' do
            let(:number) { 2 }
            it('run') do
              subject.run instance
              expect(instance.fixtures[:number]).to eq(number)
              expect(instance.finished?).to eq false
            end
          end
        end
      end
    end
  end
end
