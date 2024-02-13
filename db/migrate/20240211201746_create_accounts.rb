class CreateAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :accounts do |t|
      t.integer :balance, null: false, default: 0
      t.integer :credit_limit, null: false, default: 0

      t.timestamps
    end
  end
end
