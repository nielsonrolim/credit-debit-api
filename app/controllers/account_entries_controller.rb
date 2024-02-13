class AccountEntriesController < ApplicationController
  before_action :validate_value,
                :validate_entry_type,
                :validate_description,
                :set_account_entry_attributes,
                :check_account

  VALID_ENTRY_TYPES = %w[c d].freeze

  def create
    transaction = Account.add_account_entry(account_id: @account_id, value: @value, description: @description)
    if transaction&.dig('success')
      render json: { limite: transaction['current_limit'], saldo: transaction['current_balance'] }, status: :ok
    else
      handle_transaction_error(transaction:)
    end
  rescue ActiveRecord::ConnectionAdapters::PostgreSQL::Quoting::IntegerOutOf64BitRange
    render json: { erro: 'Valor grande demais' }, status: :unprocessable_entity
  rescue StandardError
    render json: { erro: 'Oxe!' }, status: :unprocessable_entity
  end

  private

  def permitted_params
    params.permit(:account_id, :valor, :tipo, :descricao, account_entry: {})
  end

  def validate_value
    return if permitted_params[:valor].instance_of?(Integer)

    render json: { erro: 'Valor deve ser inteiro' }, status: :unprocessable_entity and return
  end

  def validate_description
    return if permitted_params[:descricao].present? && permitted_params[:descricao] !~ /^\d/

    render json: { erro: 'Descrição inválida' }, status: :unprocessable_entity and return
  end

  def validate_entry_type
    return if VALID_ENTRY_TYPES.include? permitted_params[:tipo]&.downcase

    render json: { erro: "Tipo deve ser 'c' ou 'd'" }, status: :unprocessable_entity and return
  end

  def set_account_entry_attributes
    entry_type = permitted_params[:tipo].downcase
    @account_id = permitted_params[:account_id]
    @value = entry_type == 'c' ? permitted_params[:valor].to_i : permitted_params[:valor].to_i * -1
    @description = permitted_params[:descricao]
  end

  def check_account
    render json: { erro: 'Cliente não encontrado' }, status: :not_found and return unless Account.exists?(@account_id)
  end

  def handle_transaction_error(transaction:)
    error_message = case transaction['message']
                    when 'credit_limit_exceeded'
                      'Limite de crédito excedido'
                    else
                      'Erro desconhecido'
                    end
    render json: { erro: error_message, limite: transaction['current_limit'], saldo: transaction['current_balance'] },
           status: :unprocessable_entity
  end
end
