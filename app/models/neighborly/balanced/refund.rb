module Neighborly::Balanced
  class Refund
    FIXED_OPERATIONAL_FEE = 30 # in cents

    attr_reader :paid_resource

    def initialize(paid_resource)
      @paid_resource = paid_resource
    end

    def complete!(reason)
      debit.refund(
        amount:      resource_amount,
        description: I18n.t('neighborly.balanced.refund.description',
          resource_id:   paid_resource.id,
          resource_name: paid_resource.class.model_name.human
        ),
        meta: {
          'reason' => I18n.t("neighborly.balanced.refund_reasons.#{reason}")
        }
      )
      paid_resource.refund!
    end

    def debit
      @debit ||= ::Balanced::Debit.find("/v1/marketplaces/#{Configuration[:balanced_marketplace_id]}/debits/#{paid_resource.payment_id}")
    end

    private

    def resource_amount
      to_be_refunded = if paid_resource.payment_service_fee_paid_by_user
        paid_resource.value + paid_resource.payment_service_fee
      else
        paid_resource.value
      end
      (to_be_refunded * 100 - FIXED_OPERATIONAL_FEE).round
    end
  end
end
