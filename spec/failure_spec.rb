require 'spec_helper'

module Actionable
  describe Failure, actionable: true do
    context 'default' do
      subject { described_class.new }
      it { is_expected.to be_a described_class }
      it { expect(subject.code).to eq :failure }
      it { expect(subject.message).to eq '' }
      it { expect(subject.errors).to be_nil }
      it { expect(subject.formatted_errors).to eq '' }
      it { expect(subject.fixtures).to eq({}) }
      it { is_expected.to_not be_success }
      it { is_expected.to be_failure }
    end
    context 'custom' do
      let(:post) { TestActionable::Post.new(author: 'Myself').tap { |x| TestActionable::PostValidator.new(x).valid? } }
      let(:code) { :invalid }
      let(:message) { 'Post was invalid' }
      let(:errors) { post.errors }
      let(:fixtures) { { b: 1 } }
      subject { described_class.new code: code, message: message, errors: errors, fixtures: fixtures }
      it { is_expected.to be_a described_class }
      it { expect(subject.code).to eq code }
      it { expect(subject.message).to eq message }
      it { expect(subject.errors).to eq post.errors }
      it { expect(subject.formatted_errors).to eq "title can't be blank, publication_date can't be blank" }
      it { expect(subject.fixtures).to eq fixtures.with_indifferent_access }
      it { is_expected.to_not be_success }
      it { is_expected.to be_failure }
    end
  end
end