require 'spec_helper'

if !defined?(ActiveRecord::Base)
  puts "** require 'active_record' to run the specs in #{__FILE__}"
else
  ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

  ActiveRecord::Migration.suppress_messages do
    ActiveRecord::Schema.define(:version => 0) do
      create_table(:employers, force: true) {|t| t.string :name }
      create_table(:users, force: true) {|t| t.string :first_name; t.string :last_name; t.references :employer; }
    end
  end

  module TradesmanSpec
    class Employer < ActiveRecord::Base
      has_many :users
    end

    class User < ActiveRecord::Base
      belongs_to :employer
    end
  end
end

describe Tradesman do
  let(:adapter) { :active_record }
  before { Tradesman.configure { |config| config.set_adapter(adapter) } }

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

  context '#run' do
    context 'Create' do
      context 'when parameters are valid' do
        let(:outcome) { Tradesman::CreateUser(last_name: 'Turner') }

        it 'creates a new record' do
          expect(outcome.success?).to be true
          expect(outcome.result.id.is_a? Integer).to be true
        end

        it 'returns Horza Entity' do
          expect(outcome.result.is_a? Horza::Entities::Single).to be true
        end
      end

      context 'when parameters are invalid' do
        it 'returns an invalid outcome' do
          expect(outcome.success?).to be false
          expect(outcome.type).to eq :output_validation
        end
      end

      context 'for parent' do
        let(:employer) { TradesmanSpec::Employer.create }
        let(:outcome) { Tradesman::CreateUserForEmployer(employer.id, last_name: 'Turner') }

        it 'creates a new record' do
          expect(outcome.success?).to be true
          expect(outcome.result.id.is_a? Integer).to be true
        end

        it 'associates child with parent' do
          expect(outcome.result.employer_id).to eq employer.id
        end

        it 'associates parent with child' do
          expect(employer.reload.users.first.id).to eq outcome.result.id
        end
      end
    end
  end

  context 'Update' do
    context 'when parameters are valid' do
      let(:user) { TradesmanSpec::User.create(last_name: 'Smith') }
      let(:outcome) { Tradesman::UpdateUser(user.id, last_name: 'Turner') }

      it 'executes successfully' do
        expect(outcome.success?).to be true
      end

      it 'updates record' do
        expect(outcome.result.last_name).to eq 'Turner'
        expect(user.reload.last_name).to eq 'Turner'
      end
    end

    context 'when input parameters are invalid' do
      it 'returns an invalid outcome' do
        expect(outcome.success?).to be false
        expect(outcome.type).to eq :input_validation
      end
    end

    context 'when output parameters are invalid' do
      it 'returns an invalid outcome' do
        expect(outcome.success?).to be false
        expect(outcome.type).to eq :output_validation
      end
    end
  end

  context 'Delete' do
    context 'when parameters are valid' do
      let(:user) { TradesmanSpec::User.create }
      let(:outcome) { Tradesman::DeleteUser(user.id) }

      it 'executes successfully' do
        expect(outcome.success?).to be true
      end

      it 'deletes record' do
        expect(user.reload.destroyed?).to be true
      end
    end

    context 'when input parameters are invalid' do
      it 'returns an invalid outcome' do
        expect(outcome.success?).to be false
        expect(outcome.type).to eq :input_validation
      end
    end
  end
end
