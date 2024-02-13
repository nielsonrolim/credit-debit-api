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
class AccountEntry < ApplicationRecord
  belongs_to :account
end
