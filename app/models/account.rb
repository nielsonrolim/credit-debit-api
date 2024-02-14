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

  class << self
    def add_account_entry(account_id:, value:, description: '')
      add_account_entry_ruby(account_id:, value:, description:)
    end

    private

    def add_account_entry_pg(account_id:, value:, description: '')
      query = 'select * from add_account_entry(:account_id, :value, :description);'
      result = ActiveRecord::Base.connection.execute(
        ApplicationRecord.sanitize_sql([query, { account_id:, value:, description: }])
      )
      result&.first
    end

    # rubocop:disable Metrics/MethodLength
    def add_account_entry_ruby(account_id:, value:, description: '')
      Account.transaction do
        account = Account.select(:id, :credit_limit, :balance).lock('FOR UPDATE').find(account_id)
        new_balance = account.balance + value

        if new_balance < account.credit_limit * -1
          return { 'success' => false,
                   'message' => 'credit_limit_exceeded',
                   'current_balance' => account.balance,
                   'current_limit' => account.credit_limit }
        end

        account.update(balance: new_balance)

        account.account_entries.create(value:, description:)

        return { 'success' => true,
                 'message' => 'ok',
                 'current_balance' => new_balance,
                 'current_limit' => account.credit_limit }
      end
    end
    # rubocop:enable Metrics/MethodLength
  end

  def last_account_entries
    account_entries.order(created_at: :desc).limit(10)
  end
end
