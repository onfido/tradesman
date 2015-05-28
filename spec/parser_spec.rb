require 'spec_helper'

describe Tradesman::Parser do
  context 'when pattern is valid' do
    context 'CreateUser' do
      subject { Tradesman::Parser.new('CreateUser') }

      it 'finds a match' do
        expect(subject.match?).to be true
      end

      it 'parses the action' do
        expect(subject.action).to eq :create
      end

      it 'parses the subject' do
        expect(subject.subject).to eq :user
      end
    end

    context 'CreateUser4Employer' do
      subject { Tradesman::Parser.new('CreateUser4Employer') }

      it 'finds a match' do
        expect(subject.match?).to be true
      end

      it 'parses the action' do
        expect(subject.action).to eq :create
      end

      it 'parses the subject' do
        expect(subject.subject).to eq :user
      end

      it 'parses the parent' do
        expect(subject.parent).to eq :employer
      end
    end

    context 'DeleteCustomerInvoice' do
      subject { Tradesman::Parser.new('DeleteCustomerInvoice') }

      it 'finds a match' do
        expect(subject.match?).to be true
      end

      it 'parses the action' do
        expect(subject.action).to eq :delete
      end

      it 'parses the subject' do
        expect(subject.subject).to eq :customer_invoice
      end
    end

    context 'UpdateTransaction' do
      subject { Tradesman::Parser.new('UpdateTransaction') }

      it 'finds a match' do
        expect(subject.match?).to be true
      end

      it 'parses the action' do
        expect(subject.action).to eq :update
      end

      it 'parses the subject' do
        expect(subject.subject).to eq :transaction
      end
    end
  end

end
