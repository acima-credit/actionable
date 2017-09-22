require 'active_record'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

ActiveRecord::Schema.define(version: 1) do
  create_table :invoice do |t|
    t.integer :number
    t.datetime :date
    t.decimal :line_item_total
    t.datetime :created_at
    t.datetime :updated_at
  end
end

class Invoice < ActiveRecord::Base
end
