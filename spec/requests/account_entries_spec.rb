require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe 'AccountEntries', type: :request do
  let(:headers) { { 'Content-Type' => 'application/json' } }
  let(:account) { FactoryBot.create(:account) }
  let(:response_body) { Oj.load response.body }
  let(:valid_credit) do
    {
      valor: 20,
      tipo: 'c',
      descricao: 'anything'
    }
  end
  let(:valid_debit) do
    {
      valor: 20,
      tipo: 'd',
      descricao: 'anything'
    }
  end
  let(:invalid_transaction_decimal_value) do
    {
      valor: 20.1,
      tipo: 'c',
      descricao: 'anything'
    }
  end
  let(:invalid_transaction_decimal_value_with_comma) do
    {
      valor: '20,1',
      tipo: 'c',
      descricao: 'anything'
    }
  end
  let(:invalid_transaction_huge_value) do
    {
      valor: 200_000_000_000_000_000_000_000_000_000_000_000_000_000,
      tipo: 'c',
      descricao: 'anything'
    }
  end
  let(:invalid_transaction_inexistent_entry_type) do
    {
      valor: 20,
      tipo: 'f',
      descricao: 'anything'
    }
  end
  let(:invalid_transaction_empty_description) do
    {
      valor: 20,
      tipo: 'c',
      descricao: ''
    }
  end
  let(:invalid_transaction_null_description) do
    {
      valor: 20,
      tipo: 'c',
      descricao: nil
    }
  end

  describe 'POST /clientes/:account_id/transacoes' do
    context 'when it is a valid transaction' do
      it 'performs a credit transaction' do
        post add_account_entry_url(account.id), params: valid_credit, headers:, as: :json

        expect(response).to have_http_status(:success)
        expect(response_body['saldo']).to eq valid_credit[:valor]
      end

      it 'performs a debit transaction' do
        post add_account_entry_url(account.id), params: valid_debit, headers:, as: :json

        expect(response).to have_http_status(:success)
        expect(response_body['saldo']).to eq valid_debit[:valor] * -1
      end
    end

    context 'when it is a invalid transaction with a decimal value' do
      it 'does not perform a credit transaction' do
        post add_account_entry_url(account.id), params: invalid_transaction_decimal_value, headers:, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(account.reload.balance).to eq 0
      end
    end

    context 'when it is a invalid transaction with a decimal value with comma' do
      it 'does not perform a credit transaction' do
        post add_account_entry_url(account.id), params: invalid_transaction_decimal_value_with_comma, headers:, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(account.reload.balance).to eq 0
      end
    end

    context 'when it is a invalid transaction with a huge value' do
      it 'does not perform a credit transaction' do
        post add_account_entry_url(account.id), params: invalid_transaction_huge_value, headers:, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(account.reload.balance).to eq 0
      end
    end

    context 'when it is a invalid transaction with a inexistent entry type' do
      it 'does not performs a credit transaction' do
        post add_account_entry_url(account.id), params: invalid_transaction_inexistent_entry_type, headers:, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(account.reload.balance).to eq 0
      end
    end

    context 'when it is a invalid transaction with a empty description' do
      it 'does not performs a credit transaction' do
        post add_account_entry_url(account.id), params: invalid_transaction_empty_description, headers:, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(account.reload.balance).to eq 0
      end
    end

    context 'when it is a invalid transaction with a null description' do
      it 'does not performs a credit transaction' do
        post add_account_entry_url(account.id), params: invalid_transaction_null_description, headers:, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(account.reload.balance).to eq 0
      end
    end

    context 'when the account gone into overdraft' do
      let(:big_expense) do
        {
          valor: -995,
          tipo: 'd',
          descricao: 'anything'
        }
      end

      before { account.add_account_entry(value: big_expense[:valor], description: big_expense[:description]) }

      it 'performs a credit transaction' do
        post add_account_entry_url(account.id), params: valid_credit, headers:, as: :json

        expect(response).to have_http_status(:success)
        expect(response_body['saldo']).to eq big_expense[:valor] + valid_credit[:valor]
      end

      it 'does not perform a debit transaction' do
        post add_account_entry_url(account.id), params: valid_debit, headers:, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response_body['saldo']).to eq big_expense[:valor]
      end
    end

    context 'when account does not exist' do
      before { post add_account_entry_url(6), params: valid_credit, headers:, as: :json }

      it 'returns http success' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
