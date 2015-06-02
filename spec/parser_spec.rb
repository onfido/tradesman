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

    context 'CreateUserForEmployer' do
      subject { Tradesman::Parser.new('CreateUserForEmployer') }

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

    context 'CreateFortressForSkeletor' do
      subject { Tradesman::Parser.new('CreateFortressForSkeletor') }

      it 'finds a match' do
        expect(subject.match?).to be true
      end

      it 'parses the action' do
        expect(subject.action).to eq :create
      end

      it 'parses the subject' do
        expect(subject.subject).to eq :fortress
      end

      it 'parses the parent' do
        expect(subject.parent).to eq :skeletor
      end
    end

    context 'CreateCloudFormationForSky' do
      subject { Tradesman::Parser.new('CreateCloudFormationForSky') }

      it 'finds a match' do
        expect(subject.match?).to be true
      end

      it 'parses the action' do
        expect(subject.action).to eq :create
      end

      it 'parses the subject' do
        expect(subject.subject).to eq :cloud_formation
      end

      it 'parses the parent' do
        expect(subject.parent).to eq :sky
      end
    end

    context 'CreateWallForFortress' do
      subject { Tradesman::Parser.new('CreateWallForFortress') }

      it 'finds a match' do
        expect(subject.match?).to be true
      end

      it 'parses the action' do
        expect(subject.action).to eq :create
      end

      it 'parses the subject' do
        expect(subject.subject).to eq :wall
      end

      it 'parses the parent' do
        expect(subject.parent).to eq :fortress
      end
    end

    context 'CreateHailForCloudFormation' do
      subject { Tradesman::Parser.new('CreateHailForCloudFormation') }

      it 'finds a match' do
        expect(subject.match?).to be true
      end

      it 'parses the action' do
        expect(subject.action).to eq :create
      end

      it 'parses the subject' do
        expect(subject.subject).to eq :hail
      end

      it 'parses the parent' do
        expect(subject.parent).to eq :cloud_formation
      end
    end

    context 'UpdateFortressForSkeletor' do
      subject { Tradesman::Parser.new('UpdateFortressForSkeletor') }

      it 'finds a match' do
        expect(subject.match?).to be false
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
