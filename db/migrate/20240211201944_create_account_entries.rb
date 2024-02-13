class CreateAccountEntries < ActiveRecord::Migration[7.1]
  def change
    create_table :account_entries do |t|
      t.integer :value, null: false
      t.text :description
      t.belongs_to :account, null: false, foreign_key: true

      t.timestamps
    end
  end
end
