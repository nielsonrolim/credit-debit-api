# == Schema Information
#
# Table name: account_entries
#
#  id         :bigint           not null, primary key
#  value      :integer          not null
#  account_id :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :account_entry do
    value { 1 }
    association :account
  end
end
