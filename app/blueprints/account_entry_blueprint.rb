# AccountEntry serializer
class AccountEntryBlueprint < Blueprinter::Base
  field :value, name: :valor do |account_entry, _options|
    account_entry.value.abs
  end
  field :entry_type, name: :tipo do |account_entry, _options|
    account_entry.value.positive? ? 'c' : 'd'
  end
  field :description, name: :descricao
  field :created_at, name: :realizada_em
end
