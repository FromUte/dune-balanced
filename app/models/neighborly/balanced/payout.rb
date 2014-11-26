module Neighborly::Balanced
  class Error         < StandardError; end
  class NoBankAccount < Error;         end

  class Payout
    def initialize(project, requestor_user)
      @project   = project
      @requestor = requestor_user
    end

    def complete!(bank_account_href = nil)
      credit_project_owner!(bank_account_href)
      credit_platform!
    end

    def customer
      neighborly_customer.fetch
    end

    private

    def credit_project_owner!(bank_account_href = nil)
      to_be_credited = if bank_account_href
        Balanced::BankAccount.find(bank_account_href)
      else
        customer.bank_accounts.first
      end

      credit!(to_be_credited, financials.net_amount)
    end

    def credit_platform!
      to_be_credited =
        Balanced::Marketplace.mine.owner_customer.bank_accounts.first
      credit!(to_be_credited, financials.platform_fee)
    end

    def order
      @order ||= begin
        href = Neighborly::Balanced::Order
          .find_by(project_id: @project.id).href
        Balanced::Order.find(href)
      end
    end

    def financials
      @financials ||= ProjectFinancialByService
        .new(p, %w(balanced-bankaccount balanced-creditcard))
    end

    def neighborly_customer
      @neighborly_customer ||= Neighborly::Balanced::Customer.new(@project.user, {})
    end

    def credit!(bank_account, amount)
      if bank_account.blank?
        raise NoBankAccount, 'The customer doesn\'t have a bank account to credit.'
      end

      order.credit_to(
        amount:      in_cents(amount),
        destination: bank_account,
      )
      ::Payout.create(
        bank_account_href: bank_account.href,
        payment_service:   'balanced',
        project_id:        @project.id,
        user_id:           @requestor.id,
        value:             amount,
      )
    end

    def in_cents(amount)
      (amount * 100).round
    end
  end
end
