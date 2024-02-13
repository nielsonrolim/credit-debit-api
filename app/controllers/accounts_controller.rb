class AccountsController < ApplicationController
  def show
    account = Account.find(permitted_params[:id])
    render json: TransactionsBlueprint.render(account)
  rescue ActiveRecord::RecordNotFound
    render json: { erro: 'Cliente não encontrado' }, status: :not_found
  end

  private

  def permitted_params
    params.permit(:id)
  end
end
