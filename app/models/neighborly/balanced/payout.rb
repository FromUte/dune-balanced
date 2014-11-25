module Neighborly::Balanced
  class Error         < StandardError; end
  class NoBankAccount < Error;         end

  class Payout
    def initialize(project, requestor_user)
      @project   = project
      @requestor = requestor_user
    end

    def complete!(bank_account_href = nil)
      to_be_credited = if bank_account_href
        Balanced::BankAccount.find(bank_account_href)
      else
        customer.bank_accounts.first
      end
      if to_be_credited.blank?
        raise NoBankAccount, 'The customer doesn\'t have a bank account to credit.'
      end

      order.credit_to(
        amount:      amount_in_cents,
        destination: to_be_credited,
      )
      log_payout
    end

    def amount
      ProjectFinancialByService
        .new(@project, %w(balanced-bankaccount balanced-creditcard))
        .net_amount
    end

    def customer
      neighborly_customer.fetch
    end

    private

    def amount_in_cents
      (amount * 100).round
    end

    def order
      @order ||= begin
        href = Neighborly::Balanced::Order
          .find_by(project_id: @project.id).href
        Balanced::Order.find(href)
      end
    end

    def log_payout
      ::Payout.create(
        payment_service: 'balanced',
        project_id:      @project.id,
        user_id:         @requestor.id,
        value:           amount,
      )
    end

    def neighborly_customer
      @neighborly_customer ||= Neighborly::Balanced::Customer.new(@project.user, {})
    end
  end
end
