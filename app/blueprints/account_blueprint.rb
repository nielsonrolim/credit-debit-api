# Account serializer
class AccountBlueprint < Blueprinter::Base
  field :balance, name: :total
  field :data_extrato do |_account, _options|
    Time.zone.now.iso8601
  end
  field :credit_limit, name: :limite
end
