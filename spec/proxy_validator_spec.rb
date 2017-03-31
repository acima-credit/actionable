require 'spec_helper'

module Actionable
  describe ProxyValidator, actionable: true do
    let(:post) { TestActionable::Post.new options }
    subject { TestActionable::PostValidator.new post }
    context 'empty' do
      let(:options) { {} }
      it 'validates correctly' do
        expect(subject).to_not be_valid
        mssages = ["author can't be blank", "publication_date can't be blank", "title can't be blank"]
        # Proxy
        expect(subject.errors.full_messages.sort).to eq mssages
        expect(subject.errors['title']).to eq ["can't be blank"]
        expect(subject.errors['author']).to eq ["can't be blank"]
        expect(subject.errors['publication_date']).to eq ["can't be blank"]
        # Real
        expect(post.errors.full_messages.sort).to eq mssages
        expect(post.errors['title']).to eq ["can't be blank"]
        expect(post.errors['author']).to eq ["can't be blank"]
        expect(post.errors['publication_date']).to eq ["can't be blank"]
      end
    end
    context 'mixed' do
      let(:options) { { title: 'Some Title', publication_date: '02/17/2015' } }
      it 'validates correctly' do
        expect(subject).to_not be_valid
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
  end
end
