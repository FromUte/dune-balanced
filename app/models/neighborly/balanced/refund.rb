module Neighborly::Balanced
  class Refund
    attr_reader :contribution

    attr_reader :paid_resource

    def initialize(paid_resource)
      @paid_resource = paid_resource
    end

    def complete!(reason)
      debit.refund(
        description: I18n.t('neighborly.balanced.refund.description', resource: paid_resource.id),
        meta: {
          'reason' => I18n.t("neighborly.balanced.refund_reasons.#{reason}")
        }
      )
      paid_resource.refund!
    end

    def debit
      @debit ||= ::Balanced::Debit.find("/v1/marketplaces/#{Configuration[:balanced_marketplace_id]}/debits/#{paid_resource.payment_id}")
    end
  end
end
