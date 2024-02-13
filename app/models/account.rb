# == Schema Information
#
# Table name: accounts
#
#  id           :bigint           not null, primary key
#  balance      :integer          default(0), not null
#  credit_limit :integer          default(0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Account < ApplicationRecord
  has_many :account_entries

  def add_account_entry(value:, description: '')
    Account.add_account_entry(account_id: id, value:, description:)
  end

  def self.add_account_entry(account_id:, value:, description: '')
    query = 'select * from add_account_entry(:account_id, :value, :description);'
    result = ActiveRecord::Base.connection.execute(
      ApplicationRecord.sanitize_sql([query, { account_id:, value:, description: }])
    )
    result&.first
  end

  def last_account_entries
    account_entries.order(created_at: :desc).limit(10)
  end
end
