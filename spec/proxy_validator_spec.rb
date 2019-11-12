# frozen_string_literal: true

require 'spec_helper'

module Actionable
  describe ProxyValidator, actionable: true do
    let(:model) { TestActionable::Post }
    let(:validator) { TestActionable::PostValidator }
    let(:options) { { title: 'My Title' } }
    let(:post) { model.new options }
    subject { validator.new post }
    context 'empty' do
      let(:options) { {} }
      it 'validates correctly' do
        expect(subject).to_not be_valid
        messages = ["author can't be blank", "publication_date can't be blank", "title can't be blank"]
        # Proxy
        expect(subject.errors.full_messages.sort).to eq messages
        expect(subject.errors['title']).to eq ["can't be blank"]
        expect(subject.errors['author']).to eq ["can't be blank"]
        expect(subject.errors['publication_date']).to eq ["can't be blank"]
        # Real
        expect(post.errors.full_messages.sort).to eq messages
        expect(post.errors['title']).to eq ["can't be blank"]
        expect(post.errors['author']).to eq ["can't be blank"]
        expect(post.errors['publication_date']).to eq ["can't be blank"]
      end
    end
    context 'mixed' do
      let(:options) { { title: 'Some Title', publication_date: '02/17/2015' } }
      it 'validates correctly' do
        expect(subject).to_not be_valid
        is_expected.not_to respond_to(:xyz)
        expect { subject.xyz }.to raise_error NoMethodError, /undefined method `xyz'/
        # Proxy
        expect(subject.errors.full_messages.sort).to eq ["author can't be blank"]
        expect(subject.errors['title']).to eq []
        expect(subject.errors['author']).to eq ["can't be blank"]
        expect(subject.errors['publication_date']).to eq []
        # Real
        expect(post.errors.full_messages.sort).to eq ["author can't be blank"]
        expect(post.errors['title']).to eq []
        expect(post.errors['author']).to eq ["can't be blank"]
        expect(post.errors['publication_date']).to eq []
      end
    end
    context 'full' do
      let(:options) { { title: 'Some Title', publication_date: '02/17/2015', author: 'Paperback Writer' } }
      it 'validates correctly' do
        expect(subject).to be_valid
        # Proxy
        expect(subject.errors.full_messages.sort).to eq []
        expect(subject.errors['title']).to eq []
        expect(subject.errors['author']).to eq []
        expect(subject.errors['publication_date']).to eq []
        # Real
        expect(post.errors.full_messages.sort).to eq []
        expect(post.errors['title']).to eq []
        expect(post.errors['author']).to eq []
        expect(post.errors['publication_date']).to eq []
      end
    end
    context 'class' do
      context 'default' do
        it('has a model') { expect(validator.model).to eq model }
        it('forwards model class methods') { expect(validator.extra).to eq true }
      end
      context 'custom' do
        let(:model) { TestActionable::BadPost }
        let(:validator) { TestActionable::WrongPostValidator }
        it('has a model') { expect(validator.model).to eq model }
        it('forwards model class methods') { expect(validator.extra).to eq false }
      end
    end
  end
end
