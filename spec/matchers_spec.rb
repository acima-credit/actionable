require 'spec_helper'

module Actionable
  module RspecMatchers
    describe PerformActionableMatcher, type: :matchers do
      class SuccessWithMessageExample < Action
        action :succeed_always

        def initialize(name)
          super()
          @name = name
        end

        def succeed_always
          succeed 'I win!'
        end
      end
      class SuccessNoMessageExample < Action
        action :nothing_special

        def initialize(name)
          super()
          @name = name
        end

        def nothing_special
          @ok = true
        end
      end
      class FailureExample < Action
        action :fail_always

        def initialize(name)
          super()
          @name = name
        end

        def fail_always
          fail :my_bad, 'I failed!'
        end
      end
      class ExceptionExample < Action
        action :raise_always

        def initialize(name)
          super()
          @name = name
        end

        def raise_always
          raise StandardError, 'something went wrong'
        end
      end
      let(:name) { 'someone' }
      let(:matched) { subject.matches? klass }
      let(:failure_message) do
        matched
        subject.failure_message
      end
      describe 'actual success' do
        let(:klass) { SuccessWithMessageExample }
        context 'expected success with right message' do
          subject { described_class.new(name).and_succeed('I win!') }
          let(:message) { '' }
          it('matches') { expect(matched).to be_truthy }
          it('tells  ') { expect(failure_message).to eq message }
        end
        context 'expected success with wrong message' do
          subject { described_class.new(name).and_succeed('I always win!') }
          let(:message) do
            <<-MSG.unindent.chomp
              expected Actionable::RspecMatchers::SuccessWithMessageExample to run with ["someone"]
                and although it succeeded
                the message was "I win!" instead of "I always win!"
            MSG
          end
          it('matches') { expect(matched).to be_falsey }
          it('tells  ') { expect(failure_message).to eq message }
        end
        context 'expected failure' do
          subject { described_class.new(name).and_fail(:my_bad, 'I failed!') }
          let(:message) do
            <<-MSG.unindent.chomp
              expected Actionable::RspecMatchers::SuccessWithMessageExample to run with ["someone"]
                and fail with code :my_bad and message "I failed!"
                but it succeeded with "I win!"
            MSG
          end
          it('matches') { expect(matched).to be_falsey }
          it('tells  ') { expect(failure_message).to eq message }
        end
        context 'expected exception' do
          subject { described_class.new(name).and_raise(StandardError, 'something went wrong') }
          let(:message) do
            <<-MSG.unindent.chomp
              expected Actionable::RspecMatchers::SuccessWithMessageExample to run with ["someone"]
                and throw a StandardError exception with message "something went wrong"
                but no exception was raised
            MSG
          end
          it('matches') { expect(matched).to be_falsey }
          it('tells  ') { expect(failure_message).to eq message }
        end
        context 'expected success with no message' do
          let(:klass) { SuccessNoMessageExample }
          subject { described_class.new(name).and_succeed }
          let(:message) { '' }
          it('matches') { expect(matched).to be_truthy }
          it('tells  ') { expect(failure_message).to eq message }
        end
      end
      describe 'actual failure' do
        let(:klass) { FailureExample }
        context 'expected success' do
          subject { described_class.new(name).and_succeed('I win!') }
          let(:message) do
            <<-MSG.unindent.chomp
              expected Actionable::RspecMatchers::FailureExample to run with ["someone"]
                and succeed with message "I win!"
                but it failed with code :my_bad and message "I failed!"
            MSG
          end
          it('matches') { expect(matched).to be_falsey }
          it('tells  ') { expect(failure_message).to eq message }
        end
        context 'expected failure with the right message' do
          subject { described_class.new(name).and_fail(:my_bad, 'I failed!') }
          let(:message) { '' }
          it('matches') { expect(matched).to be_truthy }
          it('tells  ') { expect(failure_message).to eq message }
        end
        context 'expected failure with the wrong code' do
          subject { described_class.new(name).and_fail(:my_error, 'I failed!') }
          let(:message) do
            <<-MSG.unindent.chomp
              expected Actionable::RspecMatchers::FailureExample to run with ["someone"]
                and although it failed
                the code was :my_bad instead of :my_error
            MSG
          end
          it('matches') { expect(matched).to be_falsey }
          it('tells  ') { expect(failure_message).to eq message }
        end
        context 'expected failure with the wrong message' do
          subject { described_class.new(name).and_fail(:my_bad, 'I have failed!') }
          let(:message) do
            <<-MSG.unindent.chomp
              expected Actionable::RspecMatchers::FailureExample to run with ["someone"]
                and although it failed
                the message was "I failed!" instead of "I have failed!"
            MSG
          end
          it('matches') { expect(matched).to be_falsey }
          it('tells  ') { expect(failure_message).to eq message }
        end
        context 'expected failure with the wrong code and message' do
          subject { described_class.new(name).and_fail(:my_error, 'I have failed!') }
          let(:message) do
            <<-MSG.unindent.chomp
              expected Actionable::RspecMatchers::FailureExample to run with ["someone"]
                and although it failed
                the code was :my_bad instead of :my_error
                the message was "I failed!" instead of "I have failed!"
            MSG
          end
          it('matches') { expect(matched).to be_falsey }
          it('tells  ') { expect(failure_message).to eq message }
        end
        context 'expected failure with no message' do
          subject { described_class.new(name).and_fail(:my_bad) }
          let(:message) { '' }
          it('matches') { expect(matched).to be_truthy }
          it('tells  ') { expect(failure_message).to eq message }
        end
        context 'expected exception' do
          subject { described_class.new(name).and_raise(StandardError, 'something went wrong') }
          let(:message) do
            <<-MSG.unindent.chomp
              expected Actionable::RspecMatchers::FailureExample to run with ["someone"]
                and throw a StandardError exception with message "something went wrong"
                but no exception was raised
            MSG
          end
          it('matches') { expect(matched).to be_falsey }
          it('tells  ') { expect(failure_message).to eq message }
        end
      end
      describe 'actual exception' do
        let(:klass) { ExceptionExample }
        context 'expected success with message' do
          subject { described_class.new(name).and_succeed('I win!') }
          let(:message) do
            <<-MSG.unindent.chomp
              expected Actionable::RspecMatchers::ExceptionExample to run with ["someone"]
                and succeed with message "I win!"
                but a StandardError exception was raised
                  with message "something went wrong"
                  with backtrace:
                    matchers_spec.rb:51 in `raise_always'
                    method.rb:7 in `run'
                    action_runner.rb:41 in `block in run_through_main_steps'
            MSG
          end
          it('matches') { expect(matched).to be_falsey }
          it('tells  ') { expect(failure_message).to eq message }
        end
        context 'expected success with no message' do
          subject { described_class.new(name).and_succeed }
          let(:message) do
            <<-MSG.unindent.chomp
              expected Actionable::RspecMatchers::ExceptionExample to run with ["someone"]
                and succeed with message "Completed successfully."
                but a StandardError exception was raised
                  with message "something went wrong"
                  with backtrace:
                    matchers_spec.rb:51 in `raise_always'
                    method.rb:7 in `run'
                    action_runner.rb:41 in `block in run_through_main_steps'
            MSG
          end
          it('matches') { expect(matched).to be_falsey }
          it('tells  ') { expect(failure_message).to eq message }
        end
        context 'expected failure' do
          subject { described_class.new(name).and_fail(:my_bad, 'I failed!') }
          let(:message) do
            <<-MSG.unindent.chomp
              expected Actionable::RspecMatchers::ExceptionExample to run with ["someone"]
                and fail with code :my_bad and message "I failed!"
                but a StandardError exception was raised
                  with message "something went wrong"
                  with backtrace:
                    matchers_spec.rb:51 in `raise_always'
                    method.rb:7 in `run'
                    action_runner.rb:41 in `block in run_through_main_steps'
            MSG
          end
          it('matches') { expect(matched).to be_falsey }
          it('tells  ') { expect(failure_message).to eq message }
        end
        context 'expected exception with no message' do
          subject { described_class.new(name).and_raise(StandardError) }
          let(:message) { '' }
          it('matches') { expect(matched).to be_truthy }
          it('tells  ') { expect(failure_message).to eq message }
        end
        context 'expected exception with message' do
          subject { described_class.new(name).and_raise(StandardError, 'something went wrong') }
          let(:message) { '' }
          it('matches') { expect(matched).to be_truthy }
          it('tells  ') { expect(failure_message).to eq message }
        end
        context 'expected exception with the wrong exception' do
          subject { described_class.new(name).and_raise(Exception, 'something went wrong') }
          let(:message) do
            <<-MSG.unindent.chomp
              expected Actionable::RspecMatchers::ExceptionExample to run with ["someone"]
                and throw a Exception exception with message "something went wrong"
                and although an exception was raised
                  the class was StandardError
                  with backtrace:
                    matchers_spec.rb:51 in `raise_always'
                    method.rb:7 in `run'
                    action_runner.rb:41 in `block in run_through_main_steps'
            MSG
          end
          it('matches') { expect(matched).to be_falsey }
          it('tells  ') { expect(failure_message).to eq message }
        end
        context 'expected exception with the wrong message' do
          subject { described_class.new(name).and_raise(StandardError, 'oh oh') }
          let(:message) do
            <<-MSG.unindent.chomp
              expected Actionable::RspecMatchers::ExceptionExample to run with ["someone"]
                and throw a StandardError exception with message "oh oh"
                and although an exception was raised
                  the message was "something went wrong"
                  with backtrace:
                    matchers_spec.rb:51 in `raise_always'
                    method.rb:7 in `run'
                    action_runner.rb:41 in `block in run_through_main_steps'
            MSG
          end
          it('matches') { expect(matched).to be_falsey }
          it('tells  ') { expect(failure_message).to eq message }
        end
        context 'expected exception with wrong exception and message' do
          subject { described_class.new(name).and_raise(Exception, 'oh oh') }
          let(:message) do
            <<-MSG.unindent.chomp
              expected Actionable::RspecMatchers::ExceptionExample to run with ["someone"]
                and throw a Exception exception with message "oh oh"
                and although an exception was raised
                  the class was StandardError
                  the message was "something went wrong"
                  with backtrace:
                    matchers_spec.rb:51 in `raise_always'
                    method.rb:7 in `run'
                    action_runner.rb:41 in `block in run_through_main_steps'
            MSG
          end
          it('matches') { expect(matched).to be_falsey }
          it('tells  ') { expect(failure_message).to eq message }
        end
      end
    end
  end
end
