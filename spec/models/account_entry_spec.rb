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
require 'rails_helper'

RSpec.describe AccountEntry, type: :model do
  describe 'associations' do
    it { should belong_to(:account) }
  end
end
