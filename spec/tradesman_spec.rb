require 'spec_helper'

if !defined?(ActiveRecord::Base)
  puts "** require 'active_record' to run the specs in #{__FILE__}"
else
  ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

  ActiveRecord::Migration.suppress_messages do
    ActiveRecord::Schema.define(:version => 0) do
      create_table(:employers, force: true) {|t| t.string :name }
      create_table(:users, force: true) {|t| t.string :first_name; t.string :last_name; t.references :employer; }
      create_table(:strict_users, force: true) {|t| t.string :first_name; t.string :last_name; t.references :employer; }
    end
  end

  module TradesmanSpec
    class Employer < ActiveRecord::Base
      has_many :users
    end

    class User < ActiveRecord::Base
      belongs_to :employer
    end

    class StrictUser < ActiveRecord::Base
      belongs_to :employer

      validates :last_name, presence: true
    end
  end
end

describe Tradesman do
  let(:adapter) { :active_record }
  before { Tradesman.configure { |config| config.adapter = adapter } }
  after do
    TradesmanSpec::User.delete_all
    TradesmanSpec::StrictUser.delete_all
    TradesmanSpec::Employer.delete_all
  end

  context '#configure' do
    context 'when the adapter is set' do
      it 'returns the correct adapter class' do
        expect(Tradesman.adapter).to eq Horza::Adapters::ActiveRecord
      end
    end

    context 'when the adapter is not set' do
      before { Tradesman.reset }
      after { Tradesman.reset }

      it 'throws error' do
        expect { Tradesman.adapter }.to raise_error(Tradesman::Errors::Base)
      end
    end
  end

  context 'namespaces' do
    context 'when no namespaces are set' do
      it 'does not forward namespaces to Horza' do
        expect(Horza.configuration.namespaces.empty?).to be true
      end
    end
    context 'when namespaces are set' do
      before do
        Tradesman.configure { |config| config.namespaces = [TradesmanSpec] }
      end

      it 'forwards namespaces to Horza' do
        expect(Horza.configuration.namespaces).to eq [TradesmanSpec]
      end
    end
  end

  context 'development_mode' do
    context 'when development_mode is not set' do
      it 'does not forward namespaces to Horza' do
        expect(Horza.configuration.development_mode).to be nil
      end
    end
    context 'when namespaces are set' do
      before do
        Tradesman.configure { |config| config.development_mode = true }
      end

      it 'forwards namespaces to Horza' do
        expect(Horza.configuration.development_mode).to be true
      end
    end
  end

  context '#run' do
    context 'Create' do
      context 'when parameters are valid' do
        let(:outcome) { Tradesman::CreateUser.run(last_name: 'Turner') }

        it 'creates a new record' do
          expect(outcome.success?).to be true
          expect(outcome.result.id.is_a? Integer).to be true
        end

        it 'returns Horza Entity' do
          expect(outcome.result.is_a? Horza::Entities::Single).to be true
        end
      end

      context 'when parameters are invalid' do
        let(:outcome) { Tradesman::CreateStrictUser.run(first_name: 'Turner') }
        it 'returns an invalid outcome' do
          expect(outcome.success?).to be false
          expect(outcome.type).to eq :validation
        end
      end

      context 'for parent' do
        let(:employer) { TradesmanSpec::Employer.create }
        let(:outcome) { Tradesman::CreateUserForEmployer.run(parent_id: employer.id, last_name: 'Turner') }

        it 'creates a new record' do
          expect(outcome.success?).to be true
          expect(outcome.result.id.is_a? Integer).to be true
        end

        it 'associates child with parent' do
          expect(outcome.result.employer_id).to eq employer.id
        end

        it 'associates parent with child' do
          outcome
          expect(employer.users.first.id).to eq outcome.result.id
        end
      end
    end
  end

  context 'Update' do
    let(:user) { TradesmanSpec::User.create(last_name: 'Smith') }
    context 'when parameters are valid' do
      let(:outcome) { Tradesman::UpdateUser.run(id: user.id, last_name: 'Turner') }

      it 'executes successfully' do
        expect(outcome.success?).to be true
      end

      it 'updates record' do
        expect(outcome.result.last_name).to eq 'Turner'
        expect(user.reload.last_name).to eq 'Turner'
      end
    end

    context 'when parameters are invalid' do
      let(:strict_user) { TradesmanSpec::StrictUser.create(last_name: 'Smith') }
      let(:outcome) { Tradesman::UpdateStrictUser.run(id: strict_user.id, last_name: nil) }

      it 'returns an invalid outcome' do
        expect(outcome.success?).to be false
        expect(outcome.type).to eq :validation
      end
    end
  end

  context 'Delete' do
    context 'when parameters are valid' do
      let!(:user) { TradesmanSpec::User.create }
      let(:outcome) { Tradesman::DeleteUser.run(id: user.id) }

      it 'executes successfully' do
        expect(outcome.success?).to be true
        expect(outcome.result).to be true
      end

      it 'deletes record' do
        expect { outcome }.to change(TradesmanSpec::User, :count).by(-1)
      end
    end

    context 'when input parameters are invalid' do
      let(:outcome) { Tradesman::DeleteUser.run(id: 999) }
      it 'returns an invalid outcome' do
        expect(outcome.success?).to be false
        expect(outcome.type).to eq :validation
      end
    end
  end
end
