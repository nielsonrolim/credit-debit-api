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
require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Account, type: :model do
  let(:account) { FactoryBot.create(:account) }
  let(:positive_value) { 10 }
  let(:negative_value) { -10 }
  let(:description) { 'Anything' }

  describe 'associations' do
    it { should have_many(:account_entries) }
  end

  describe '#add_account_entry' do
    before do
      allow(Account).to receive(:add_account_entry).with(account_id: account.id, value: anything, description: anything)
                                                   .and_return(
                                                     { 'success' => true,
                                                       'message' => 'ok',
                                                       'current_balance' => 100_000,
                                                       'current_limit' => -99_930 }
                                                   )
    end

    it 'calls Account.add_account_entry with account id and a positive value' do
      account.add_account_entry(value: positive_value, description:)
      expect(Account).to have_received(:add_account_entry).with(account_id: account.id,
                                                                value: positive_value,
                                                                description:)
    end

    it 'calls Account.add_account_entry with account id and a negative value' do
      account.add_account_entry(value: negative_value, description:)
      expect(Account).to have_received(:add_account_entry).with(account_id: account.id,
                                                                value: negative_value,
                                                                description:)
    end
  end

  describe '.add_account_entry' do
    context 'when the account has credit limit' do
      it 'allows a debit to the account' do
        transaction = Account.add_account_entry(account_id: account.id, value: negative_value)

        expect(transaction&.dig('success')).to eq true
        expect(transaction&.dig('current_balance')).to eq account.reload.balance
      end

      it 'allows a credit to the account' do
        transaction = Account.add_account_entry(account_id: account.id, value: positive_value)

        expect(transaction&.dig('success')).to eq true
        expect(transaction&.dig('current_balance')).to eq account.reload.balance
      end
    end

    context 'when the account gone into overdraft' do
      let(:overdraft_account) { FactoryBot.create(:overdraft_account) }

      it 'does not allow debit beyond the credit limit' do
        transaction = Account.add_account_entry(account_id: overdraft_account.id, value: negative_value)

        expect(transaction&.dig('success')).to eq false
        expect(transaction&.dig('current_balance')).to eq overdraft_account.reload.balance
      end

      it 'allows a credit to the account' do
        transaction = Account.add_account_entry(account_id: overdraft_account.id, value: positive_value)

        expect(transaction&.dig('success')).to eq true
        expect(transaction&.dig('current_balance')).to eq overdraft_account.reload.balance
      end

      it 'allows a debit to the account after a deposit' do
        Account.add_account_entry(account_id: overdraft_account.id, value: positive_value)
        transaction = Account.add_account_entry(account_id: overdraft_account.id, value: positive_value)

        expect(transaction&.dig('success')).to eq true
        expect(transaction&.dig('current_balance')).to eq overdraft_account.reload.balance
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
