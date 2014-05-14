require 'spec_helper'

describe Neighborly::Balanced::Refund do
  let(:payable_resource) do
    double(
      id:                               '1',
      payment_id:                       '1234567890',
      value:                            100,
      payment_service_fee:              2,
      payment_service_fee_paid_by_user: true,
      refund!:                          nil
    )
  end
  let(:debit) { double('Debit', refund: nil) }
  subject { described_class.new(payable_resource) }

  before do
    Configuration.stub(:[]).with(:balanced_marketplace_id).and_return('qwe')
  end

  describe 'debit' do
    it 'gets the debit object through Balanced API' do
      Balanced::Debit.stub(:find).
        with('/v1/marketplaces/qwe/debits/1234567890').
        and_return(debit)
      expect(subject.debit).to eql(debit)
    end
  end

  describe 'completion' do
    before { subject.stub(:debit).and_return(debit) }

    it 'performs a refund through Balanced API for the given contribution' do
      expect(debit).to receive(:refund)
      subject.complete!(:match_automatic)
    end

    it 'sets the contribution as refunded' do
      expect(contribution).to receive(:refund!)
      subject.complete!(:match_automatic)
    end
  end
end
