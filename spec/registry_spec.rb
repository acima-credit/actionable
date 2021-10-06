# frozen_string_literal: true

require 'spec_helper'

module Actionable
  describe Registry do
    context 'instance' do
      subject { Actionable.registry }
      let(:exp_keys) do
        %w[
          Actionable::RspecMatchers::ExceptionExample
          Actionable::RspecMatchers::FailureExample
          Actionable::RspecMatchers::SuccessNoMessageExample
          Actionable::RspecMatchers::SuccessWithMessageExample
          TestActionable::AddTwo
          TestActionable::BangAction
          TestActionable::BaseAction
          TestActionable::CaseAction
          TestActionable::ComposedAction
          TestActionable::ComposedConditionalAction
          TestActionable::ConditionalAction
          TestActionable::ControlledComposedAction
          TestActionable::ExplicitTransactionOptions
          TestActionable::ExtraComposedAction
          TestActionable::FailOnAddAction
          TestActionable::FinalAction
          TestActionable::GreatAction
          TestActionable::LoggingAction
          TestActionable::OverComposedAction
          TestActionable::SafeNestingTransaction
          TestActionable::SmallAction
        ]
      end
      it { expect(subject.size).to eq 21 }
      it { expect(subject.keys.sort).to eq exp_keys }
      it { expect(subject.values.size).to eq 21 }
      it { expect(subject.empty?).to eq false }
      it { expect(subject['TestActionable::AddTwo']).to eq TestActionable::AddTwo }
    end
  end
end
