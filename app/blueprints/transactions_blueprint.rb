# Transations serializer
class TransactionsBlueprint < Blueprinter::Base
  association :saldo, blueprint: AccountBlueprint do |account, _options|
    account
  end

  association :ultimas_transacoes, blueprint: AccountEntryBlueprint do |account, _options|
    account.last_account_entries
  end
end
