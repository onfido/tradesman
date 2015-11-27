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

describe Tradesman do
  let(:adapter) { :active_record }
  before { Tradesman.configure { |config| config.adapter = adapter } }
  after do
    User.delete_all
    StrictUser.delete_all
    Employer.delete_all
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
        expect { Tradesman.adapter }.to raise_error(Horza::Errors::AdapterError)
      end
    end
  end


  context '#go' do
    context 'Create' do
      context 'when parameters are valid' do
        let(:outcome) { Tradesman::CreateUser.go(last_name: 'Turner') }

        it 'creates a new record' do
          expect(outcome.success?).to be true
          expect(outcome.result.id.is_a? Integer).to be true
        end

        it 'returns Horza Entity' do
          expect(outcome.result.is_a? Horza::Entities::Single).to be true
        end
      end

      context 'when parameters are invalid' do
        let(:outcome) { Tradesman::CreateStrictUser.go(first_name: 'Turner') }
        it 'returns an invalid outcome' do
          expect(outcome.success?).to be false
          expect(outcome.type).to eq :validation
        end
      end

      context 'multiple records' do
        let(:outcome) { Tradesman::CreateStrictUser.go(param_list) }
        context 'when all are valid' do
          let(:param_list) { [{ last_name: 'Turner' }, { last_name: 'Smith' }, { last_name: 'Jones' }] }

          it 'creates one record for each parameter set passed' do
            expect(outcome.result.length).to eq param_list.length
            outcome.result.each do |record|
              expect(record.id.present?).to be true
            end
          end
        end

        context 'when one is valid' do
          let(:param_list) { [{ first_name: 'Turner' }, { last_name: 'Smith' }, { age: 25 }] }

          it 'creates invalid entities when params are invalid, valid entity otherwise' do
            entities = outcome.result
            expect(entities.length).to eq param_list.length

            expect(entities.first.id).to be nil
            expect(entities.first.valid?).to be false

            expect(entities.second.id.is_a? Integer).to be true

            expect(entities.third.id).to be nil
            expect(entities.third.valid?).to be false
          end
        end
      end

      context 'for parent' do
        let(:employer) { Employer.create }
        let(:outcome) { Tradesman::CreateUserForEmployer.go(employer.id, last_name: 'Turner') }

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

        context 'multiple records' do
          let(:employer) { Tradesman::CreateEmployer.go({}).result }
          let(:outcome) { Tradesman::CreateStrictUserForEmployer.go(employer, param_list) }
          context 'when all are valid' do
            let(:param_list) { [{ last_name: 'Turner' }, { last_name: 'Smith' }, { last_name: 'Jones' }] }

            it 'creates one record for each parameter set passed' do
              expect(outcome.result.length).to eq param_list.length
              outcome.result.each do |record|
                expect(record.id.present?).to be true
              end
            end
          end

          context 'when one is valid' do
            let(:param_list) { [{ first_name: 'Turner' }, { last_name: 'Smith' }, { age: 25 }] }

            it 'creates invalid entities when params are invalid, valid entity otherwise' do
              entities = outcome.result
              expect(entities.length).to eq param_list.length

              expect(entities.first.id).to be nil
              expect(entities.first.valid?).to be false

              expect(entities.second.id.is_a? Integer).to be true

              expect(entities.third.id).to be nil
              expect(entities.third.valid?).to be false
            end
          end
        end
      end
    end
  end

  context 'Update' do
    let(:user) { User.create(last_name: 'Smith') }
    context 'when parameters are valid' do
      let(:outcome) { Tradesman::UpdateUser.go(user.id, last_name: 'Turner') }

      it 'executes successfully' do
        expect(outcome.success?).to be true
      end

      it 'updates record' do
        expect(outcome.result.last_name).to eq 'Turner'
        expect(user.reload.last_name).to eq 'Turner'
      end
    end

    context 'when parameters are invalid' do
      let(:strict_user) { StrictUser.create(last_name: 'Smith') }
      let(:outcome) { Tradesman::UpdateStrictUser.go(strict_user, last_name: nil) }

      it 'returns an invalid outcome' do
        expect(outcome.success?).to be false
        expect(outcome.type).to eq :validation
      end
    end

    context 'when id is invalid' do
      it 'throws error' do
        expect { Tradesman::UpdateStrictUser.go('not_an_integer', last_name: nil) }.to raise_error Tradesman::InvalidId
      end
    end

    context 'multiple records' do
      let(:valid_params) { { last_name: 'Turner' } }
      let(:outcome) { Tradesman::UpdateStrictUser.go(records, params) }

      # Hash of id => params
      # Tradesman::UpdateStrictUser.go(hash.keys, hash.values)

      context 'passing array of ids and one valid parameter set' do
        let(:records) { Tradesman::CreateStrictUser.go([valid_params, valid_params, valid_params]).result }
        let(:params) { { last_name: 'Smith' } }

        it 'creates one record for each parameter set passed' do
          expect(outcome.result.length).to eq records.length
          outcome.result.each do |record|
            expect(record.last_name).to eq 'Smith'
            expect(record.id.present?).to be true
          end
        end
      end

      context 'passing array of ids and multiple valid parameters' do
        let(:records) { Tradesman::CreateStrictUser.go([valid_params, valid_params, valid_params]).result }
        let(:params) { [{ last_name: 'Smith' }, { last_name: 'Williams' }, { last_name: 'Jones' }] }

        it 'creates one record for each parameter set passed' do
          results = outcome.result
          expect(results.length).to eq records.length
          expect(results.first.last_name).to eq params.first[:last_name]
          expect(results.second.last_name).to eq params.second[:last_name]
          expect(results.last.last_name).to eq params.last[:last_name]
        end
      end

      context 'passing query hash and single valid parameters' do
        let(:query_params) { { last_name: 'Smith' } }
        let(:update_params) { { last_name: 'Turner' } }
        let(:other_params) { { last_name: 'Sharkasy' } }
        let!(:records) { Tradesman::CreateStrictUser.go([valid_params, valid_params, valid_params]).result }
        let!(:extraneous_records) { Tradesman::CreateStrictUser.go([other_params, other_params]).result }

        before do
          Tradesman::CreateStrictUser.go([query_params, query_params, query_params])
        end
        it 'updates all records that match the query' do
          outcome = Tradesman::UpdateStrictUser.go(query_params, update_params)
          expect(outcome.success?).to be true
          expect(outcome.result.length).to eq 3
          expect(outcome.result.first.last_name).to eq 'Turner'
          expect(outcome.result.last.last_name).to eq 'Turner'
        end
      end
    end
  end

  context 'Delete' do
    context 'when parameters are valid' do
      let!(:user) { User.create }
      let(:outcome) { Tradesman::DeleteUser.go(user) }

      it 'executes successfully' do
        expect(outcome.success?).to be true
        expect(outcome.result).to be true
      end

      it 'deletes record' do
        expect { outcome }.to change(User, :count).by(-1)
      end
    end

    context 'when input parameters are invalid' do
      let(:outcome) { Tradesman::DeleteUser.go(999) }
      it 'returns an invalid outcome' do
        expect(outcome.success?).to be false
        expect(outcome.type).to eq :validation
      end
    end

    context 'multiple records' do
      let(:valid_params) { { last_name: 'Turner' } }
      let(:outcome) { Tradesman::DeleteStrictUser.go(records) }

      context 'passing array of ids' do
        let(:records) { Tradesman::CreateStrictUser.go([valid_params, valid_params, valid_params]).result }

        it 'deletes all records' do
          expect(outcome.result.length).to eq records.length
          expect(outcome.result.uniq.first).to eq true
        end
      end

      context 'passing query hash and single valid parameters' do
        let(:query_params) { { last_name: 'Smith' } }
        let(:update_params) { { last_name: 'Turner' } }
        let(:records) { Tradesman::CreateStrictUser.go([valid_params, valid_params, valid_params]).result }

        before do
          Tradesman::CreateStrictUser.go([query_params, query_params, query_params])
        end
        it 'updates all records that match the query' do
          outcome = Tradesman::DeleteStrictUser.go(query_params)
          expect(outcome.success?).to be true
          expect(outcome.result.length).to eq 3
          expect(outcome.result.first).to be true
          expect(outcome.result.second).to be true
          expect(outcome.result.third).to be true
        end
      end
    end
  end

  context '#go!' do
    context 'Create' do
      context 'when parameters are valid' do
        let(:outcome) { Tradesman::CreateUser.go!(last_name: 'Turner') }

        it 'creates a new record' do
          expect(outcome.success?).to be true
          expect(outcome.result.id.is_a? Integer).to be true
        end

        it 'returns Horza Entity' do
          expect(outcome.result.is_a? Horza::Entities::Single).to be true
        end
      end

      context 'when parameters are invalid' do
        let(:outcome) { Tradesman::CreateStrictUser.go!({}) }
        it 'throws error' do
          expect { outcome }.to raise_error Tradesman::Invalid
        end
      end

      context 'for parent' do
        let(:employer) { Employer.create }
        let(:outcome) { Tradesman::CreateUserForEmployer.go!(employer.id, last_name: 'Turner') }

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
    let(:user) { User.create(last_name: 'Smith') }
    context 'when parameters are valid' do
      let(:outcome) { Tradesman::UpdateUser.go!(user.id, last_name: 'Turner') }

      it 'executes successfully' do
        expect(outcome.success?).to be true
      end

      it 'updates record' do
        expect(outcome.result.last_name).to eq 'Turner'
        expect(user.reload.last_name).to eq 'Turner'
      end
    end

    context 'when parameters are invalid' do
      let(:strict_user) { StrictUser.create(last_name: 'Smith') }
      let(:outcome) { Tradesman::UpdateStrictUser.go!(strict_user, last_name: nil) }

      it 'throws error' do
        expect { outcome }.to raise_error Tradesman::Invalid
      end
    end
  end

  context 'Delete' do
    context 'when parameters are valid' do
      let!(:user) { User.create }
      let(:outcome) { Tradesman::DeleteUser.go!(user) }

      it 'executes successfully' do
        expect(outcome.success?).to be true
        expect(outcome.result).to be true
      end

      it 'deletes record' do
        expect { outcome }.to change(User, :count).by(-1)
      end
    end

    context 'when input parameters are invalid' do
      let(:outcome) { Tradesman::DeleteUser.go(999) }
      it 'returns an invalid outcome' do
        expect(outcome.success?).to be false
        expect(outcome.type).to eq :validation
      end
    end
  end
end
