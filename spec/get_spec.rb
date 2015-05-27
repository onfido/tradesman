require 'spec_helper'

if !defined?(ActiveRecord::Base)
  puts "** require 'active_record' to run the specs in #{__FILE__}"
else
  ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

  ActiveRecord::Migration.suppress_messages do
    ActiveRecord::Schema.define(:version => 0) do
      create_table(:employers, force: true) {|t| t.string :name }
      create_table(:users, force: true) {|t| t.string :first_name; t.string :last_name; t.references :employer; }
      create_table(:sports_cars, force: true) {|t| t.string :make; t.references :employer; }
    end
  end

  module TradesmanSpec
    class Employer < ActiveRecord::Base
      has_many :users
      has_many :sports_cars
    end

    class User < ActiveRecord::Base
      belongs_to :employer
    end

    class SportsCar < ActiveRecord::Base
      belongs_to :employer
    end
  end
end
