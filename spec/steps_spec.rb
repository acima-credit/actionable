# frozen_string_literal: true

require 'spec_helper'

module Actionable
  describe Steps do
    context '.build' do
      let(:options) { { if: :ok? } }
      let(:result) { described_class.build name, options }
      context 'string' do
        let(:klass) { Steps::Method }
        let(:name) { 'hello' }
        let(:str) { '#<Actionable::Steps::Method name="hello", options={:if=>:ok?}>' }
        it('class  ') { expect(result.class.name).to eq klass.name }
        it('string ') { expect(result.to_s).to eq str }
        it('inspect') { expect(result.inspect).to eq str }
      end
      context 'symbol' do
        let(:klass) { Steps::Method }
        let(:name) { :hello }
        let(:str) { '#<Actionable::Steps::Method name="hello", options={:if=>:ok?}>' }
        it('class  ') { expect(result.class.name).to eq klass.name }
        it('string ') { expect(result.to_s).to eq str }
        it('inspect') { expect(result.inspect).to eq str }
      end
      context 'action' do
        let(:klass) { Steps::Action }
        let(:name) { TestActionable::SmallAction }
        let(:str) { '#<Actionable::Steps::Action name="test_actionable/small_action", options={:if=>:ok?}>' }
        it('class  ') { expect(result.class.name).to eq klass.name }
        it('string ') { expect(result.to_s).to eq str }
        it('inspect') { expect(result.inspect).to eq str }
      end
    end
  end
end
