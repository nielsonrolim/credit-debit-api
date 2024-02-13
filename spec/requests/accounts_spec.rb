require 'rails_helper'

RSpec.describe 'Accounts', type: :request do
  let(:account) { FactoryBot.create(:positive_account) }

  describe 'GET /clientes/:id/extrato' do
    let(:response_body) { Oj.load response.body }

    context 'when account exists' do
      before { get transactions_url(account.id) }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns the correct balance' do
        expect(response_body['saldo']['total']).to eq account.balance
      end

      it 'returns the correct credit limit' do
        expect(response_body['saldo']['limite']).to eq account.credit_limit
      end

      it 'has the correct number of account entries' do
        expect(response_body['ultimas_transacoes'].size).to eq account.last_account_entries.count
      end
    end

    context 'when account does not exist' do
      before { get transactions_url(6) }

      it 'returns http success' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
