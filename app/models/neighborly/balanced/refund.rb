module Neighborly::Balanced
  class Refund
    attr_reader :contribution

    def initialize(contribution)
      @contribution = contribution
    end

    def complete!(reason)
      debit.refund(
        description: I18n.t('en.neighborly.balanced.refund.description', contribution: contribution.id),
        meta: {
          'reason' => I18n.t("en.neighborly.balanced.refund_reason.#{reason}")
        }
      )
      contribution.refund!
    end

    def debit
      @debit ||= ::Balanced::Debit.find("/v1/marketplaces/#{Configuration[:balanced_marketplace_id]}/debits/#{contribution.payment_id}")
    end
  end
end
