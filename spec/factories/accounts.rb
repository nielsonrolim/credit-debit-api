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
FactoryBot.define do
  factory :account do
    balance { 0 }
    credit_limit { 1000 }

    factory :overdraft_account do
      balance { -995 }
      after(:create) do |account|
        create(:account_entry, account:, value: -995, description: 'anything')
      end
    end

    factory :positive_account do
      balance { 90 }
      after(:create) do |account|
        3.times do
          create(:account_entry, account:, value: 30, description: 'anything')
        end
      end
    end
  end
end
