# frozen_string_literal: true

require 'spec_helper'

module Actionable
  describe Action do
    subject { klass.run number }
    context 'class' do
      let(:klass) { TestActionable::GreatAction }
      it { expect(klass.model).to eq Invoice }
      it { expect(klass.steps.map(&:name)).to eq %w[fail_for_2 add_one add_two] }
      it { expect(klass.method(:call)).to eq klass.method(:run) }
      it { expect(klass.action_name).to eq 'test_actionable/great_action' }
      it { expect(klass.measure).to eq :all }

      context 'with a step added more than once' do
        before do
          10.times do
            klass.step(:fail_for_2)
          end
        end

        it { expect(klass.steps.map(&:name)).to eq %w[fail_for_2 add_one add_two] }
      end
    end
    context 'result' do
      let(:klass) { TestActionable::GreatAction }
      context 'success' do
        let(:number) { 10 }
        it { is_expected.to be_a Actionable::Success }
        it { expect(subject.code).to eq :success }
        it { expect(subject.message).to eq 'Completed successfully.' }
        it { expect(subject.fixtures).to eq('number' => 13) }
        context 'history' do
          # TestActionable::GreatAction : subject.history | [
          #   ["main", "fail_for_2", "2019-11-01T16:04:42.325-06:00", "0.000010", "na", nil],
          #   ["main", "add_one", "2019-11-01T16:04:42.325-06:00", "0.000008", "na", nil],
          #   ["main", "add_two", "2019-11-01T16:04:42.325-06:00", "0.000006", "na", nil]
          # ]
          it('type   ') { expect(subject.history).to be_a Actionable::History }
          it('section') { expect(subject.history.map(&:section)).to eq(%i[main main main]) }
          it('name   ') { expect(subject.history.map(&:name)).to eq(%w[fail_for_2 add_one add_two]) }
          it('[name1]') { expect(subject.history['fail_for_2']).to be_a Actionable::History::Step }
          it('[name2]') { expect(subject.history[:add_one]).to be_a Actionable::History::Step }
          it('[name3]') { expect(subject.history['add_two']).to be_a Actionable::History::Step }
          it('[name4]') { expect(subject.history[:unknown]).to eq nil }
          it('time   ') { expect(subject.history.map { |x| x.start_time.to_s[0, 19] }.uniq).to eq([Time.now.to_s[0, 19]]) }
          it('took   ') { expect(subject.history.map(&:took).all? { |x| x > 0.0 && x < 0.0002 }).to eq true }
          it('code   ') { expect(subject.history.map(&:code)).to eq(%i[na na na]) }
          it('history') { expect(subject.history.map(&:history)).to eq([nil, nil, nil]) }
        end
        it do
          msg = nil
          klass.run(number) { |x| msg = x.message }
          expect(msg).to eq 'Completed successfully.'
        end
      end
      context 'failure' do
        let(:number) { 2 }
        it { is_expected.to be_a Actionable::Failure }
        it { expect(subject.code).to eq :bad_number }
        it { expect(subject.message).to eq 'Wrong number' }
        it { expect(subject.fixtures).to eq('number' => 2) }
        it do
          msg = nil
          klass.run(number) { |x| msg = x.message }
          expect(msg).to be_nil
        end
        context 'history' do
          # TestActionable::GreatAction : subject.history | [
          #   ["main", "fail_for_2", "2019-11-01T16:03:51.757-06:00", "0.000098", "bad_number", nil]
          # ]
          it('type   ') { expect(subject.history).to be_a Actionable::History }
          it('section') { expect(subject.history.map(&:section)).to eq(%i[main]) }
          it('name   ') { expect(subject.history.map(&:name)).to eq(['fail_for_2']) }
          it('time   ') { expect(subject.history.map { |x| x.start_time.to_s[0, 19] }.uniq).to eq([Time.now.to_s[0, 19]]) }
          it('took   ') { expect(subject.history.map(&:took).all? { |x| x > 0.0 && x < 0.0002 }).to eq true }
          it('code   ') { expect(subject.history.map(&:code)).to eq([:bad_number]) }
          it('history') { expect(subject.history.map(&:history)).to eq([nil]) }
        end
      end
    end
    context 'composed' do
      context 'single' do
        let(:klass) { TestActionable::ComposedAction }
        context 'class' do
          it { expect(klass.steps.map(&:name)).to eq %w[test_actionable/small_action add_five] }
          it { expect(klass.action_name).to eq 'test_actionable/composed_action' }
        end
        context 'result' do
          context 'success' do
            let(:number) { 10 }
            it { expect(subject.success?).to eq true }
            it { expect(subject.fixtures).to eq('number' => 18) }
            context 'history' do
              # TestActionable::ComposedAction : subject.history | [
              #   ["main", "test_actionable/small_action", "2019-11-01T16:00:00.528-06:00", "0.000310", "success", nil],
              #   ["main", "add_five", "2019-11-01T16:00:00.528-06:00", "0.000017", "na", nil]
              # ]
              it('type   ') { expect(subject.history).to be_a Actionable::History }
              it('section') { expect(subject.history.map(&:section)).to eq(%i[main main]) }
              it('name   ') { expect(subject.history.map(&:name)).to eq(%w[test_actionable/small_action add_five]) }
              it('time   ') { expect(subject.history.map { |x| x.start_time.to_s[0, 19] }.uniq).to eq([Time.now.to_s[0, 19]]) }
              it('took   ') { expect(subject.history.map(&:took).all? { |x| x > 0.0 && x < 0.01 }).to eq true }
              it('code   ') { expect(subject.history.map(&:code)).to eq(%i[success na]) }
              context 'nested' do
                let(:nested) { subject.history.map(&:history) }
                let(:first) { nested.first }
                let(:last) { nested.last }
                it { expect(nested.size).to eq 2 }
                it 'first' do
                  expect(first).to be_a Actionable::History
                  expect(first.map(&:section)).to eq %i[main main]
                  expect(first.map(&:name)).to eq %w[fail_on_six add_three]
                  expect(first.map { |x| x.start_time.to_s[0, 19] }.uniq).to eq([Time.now.to_s[0, 19]])
                  expect(first.map(&:took).all? { |x| x > 0.0 && x < 0.001 }).to eq true
                  expect(first.map(&:code)).to eq %i[na na]
                end
                it('last') { expect(last).to eq nil }
              end
            end
          end
          context 'failure' do
            let(:number) { 6 }
            it { expect(subject.success?).to eq false }
            it { expect(subject.fixtures).to eq('number' => 6) }
            context 'history' do
              # TestActionable::ComposedAction : subject.history | [
              #   ["main", "test_actionable/small_action", "2019-11-01T16:02:59.711-06:00", "0.000163", "fail", nil]
              # ]
              it('type   ') { expect(subject.history).to be_a Actionable::History }
              it('section') { expect(subject.history.map(&:section)).to eq(%i[main]) }
              it('name   ') { expect(subject.history.map(&:name)).to eq(%w[test_actionable/small_action]) }
              it('time   ') { expect(subject.history.map { |x| x.start_time.to_s[0, 19] }.uniq).to eq([Time.now.to_s[0, 19]]) }
              it('took   ') { expect(subject.history.map(&:took).all? { |x| x > 0.0 && x < 0.01 }).to eq true }
              it('code   ') { expect(subject.history.map(&:code)).to eq([:fail]) }
              context 'nested' do
                let(:nested) { subject.history.map(&:history) }
                let(:first) { nested.first }
                it { expect(nested.size).to eq 1 }
                it 'first' do
                  expect(first).to be_a Actionable::History
                  expect(first.map(&:section)).to eq %i[main]
                  expect(first.map(&:name)).to eq %w[fail_on_six]
                  expect(first.map { |x| x.start_time.to_s[0, 19] }.uniq).to eq([Time.now.to_s[0, 19]])
                  expect(first.map(&:took).all? { |x| x > 0.0 && x < 0.001 }).to eq true
                  expect(first.map(&:code)).to eq %i[bad_number]
                end
              end
            end
          end
        end
      end
      context 'multiple' do
        let(:klass) { TestActionable::OverComposedAction }
        context 'class' do
          it { expect(klass.steps.map(&:name)).to eq %w[add_five test_actionable/composed_action add_ten] }
          it { expect(klass.action_name).to eq 'test_actionable/over_composed_action' }
        end
        context 'result' do
          context 'success' do
            let(:number) { 10 }
            it { expect(subject.success?).to eq true }
            it { expect(subject.fixtures).to eq('number' => 33) }
          end
          context 'failure' do
            let(:number) { 1 }
            it { expect(subject.success?).to eq false }
            it { expect(subject.fixtures).to eq('number' => 6) }
          end
        end
      end
      context 'with named fixtures' do
        let(:klass) { TestActionable::ControlledComposedAction }
        context 'result' do
          let(:number) { 10 }
          it { expect(subject.success?).to eq true }
          it { expect(subject.fixtures).to eq('number' => 14, 'extra_one' => true) }
          it { expect(subject).to respond_to(:number) }
          it { expect(subject).to respond_to(:extra_one) }
          it { expect(subject).to_not respond_to(:extra_two) }
        end
      end
      context 'conditional' do
        let(:klass) { TestActionable::ComposedConditionalAction }
        context 'class' do
          it { expect(klass.steps.map(&:name)).to eq %w[test_actionable/fail_on_add_action add_five] }
          it { expect(klass.action_name).to eq 'test_actionable/composed_conditional_action' }
        end
        context 'result' do
          context 'success running nested action' do
            let(:number) { 1 }
            it { expect(subject.success?).to eq true }
            it { expect(subject.fixtures).to eq('number' => 9) }
          end
          context 'success skipping nested action' do
            let(:number) { 2 }
            it { expect(subject.success?).to eq true }
            it { expect(subject.fixtures).to eq('number' => 7) }
          end
          context 'failure' do
            let(:number) { 3 }
            it { expect(subject.success?).to eq false }
            it { expect(subject.fixtures).to eq('number' => 6) }
          end
        end
      end
    end
    context 'conditional' do
      let(:klass) { TestActionable::ConditionalAction }
      context 'if' do
        let(:number) { 1 }
        it { expect(subject.number).to eq 5 }
      end
      context 'unless' do
        let(:number) { 3 }
        it { expect(subject.number).to eq 3 }
      end
    end
    context 'case' do
      let(:klass) { TestActionable::CaseAction }
      context 'first step' do
        let(:number) { 1 }
        it { expect(subject.number).to eq 2 }
      end
      context 'second step' do
        let(:number) { 2 }
        it { expect(subject.number).to eq 4 }
      end
      context 'default step' do
        let(:number) { 3 }
        it { expect(subject.number).to eq 6 }
      end
    end
    context 'final' do
      let(:klass) { TestActionable::FinalAction }
      context 'class' do
        it { expect(klass.steps.map(&:name)).to eq %w[add_one fail_for_2] }
        it { expect(klass.success_steps.map(&:name)).to eq %w[add_two] }
        it { expect(klass.failure_steps.map(&:name)).to eq %w[add_three] }
        it { expect(klass.always_steps.map(&:name)).to eq %w[add_five] }
        it { expect(klass.action_name).to eq 'test_actionable/final_action' }
      end
      context 'result' do
        context 'on success' do
          let(:number) { 3 }
          it { expect(subject.number).to eq 11 }
        end
        context 'on failure' do
          let(:number) { 1 }
          it { expect(subject.number).to eq 10 }
        end
      end
    end
    context 'bang' do
      let(:klass) { TestActionable::BangAction }
      subject { klass.run letter }
      context 'class' do
        it { expect(klass.steps.map(&:name)).to eq %w[fail_for_x succeed_for_y ok_for_others] }
        it { expect(klass.success_steps.map(&:name)).to eq [] }
        it { expect(klass.failure_steps.map(&:name)).to eq [] }
        it { expect(klass.always_steps.map(&:name)).to eq [] }
        it { expect(klass.action_name).to eq 'test_actionable/bang_action' }
      end
      context 'result' do
        context 'on failure!' do
          let(:letter) { :x }
          it { expect(subject.final).to eq '[x]' }
        end
        context 'on success!' do
          let(:letter) { :y }
          it { expect(subject.final).to eq '[y] > x' }
        end
        context 'on other' do
          let(:letter) { :z }
          it { expect(subject.final).to eq '[z] > x > y > ok' }
        end
      end
    end
    context 'logging' do
      let(:klass) { TestActionable::LoggingAction }
      let(:number) { 1 }
      subject { klass.run number }
      context 'result' do
        context 'on success' do
          before do
            expect_logs :info,
                        'TestActionable::LoggingAction : initialize | @number = 1',
                        'TestActionable::LoggingAction : run | running with a transaction from Invoice',
                        'TestActionable::LoggingAction : block in run_through_main_steps | add_one : start ...',
                        'TestActionable::LoggingAction : add_one | 1 + 1 = 2',
                        'TestActionable::LoggingAction : block in run_through_main_steps | add_two : start ...',
                        'TestActionable::LoggingAction : add_two | 2 + 2 = 4',
                        'TestActionable::LoggingAction : finalize_if_necessary | step : finalizing ...',
                        'TestActionable::LoggingAction : succeed | message : Completed successfully.',
                        'TestActionable::LoggingAction : run | result : success : Completed successfully.'
          end
          it { subject }
        end
      end
    end
  end
end
