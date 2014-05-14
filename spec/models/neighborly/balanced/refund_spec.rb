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
    let(:operational_fee) { described_class::FIXED_OPERATIONAL_FEE }

    it 'performs a refund through Balanced API for the given payable_resource' do
      expect(debit).to receive(:refund)
      subject.complete!(:match_automatic)
    end

    context 'when contributor paid payment service fees' do
      before do
        payable_resource.stub(:payment_service_fee_paid_by_user).and_return(true)
      end

      it 'refunds them using cents unit, except by fixed operational fee' do
        expect(debit).to receive(:refund).with(hash_including(amount: 10200 - operational_fee))
        subject.complete!(:match_automatic)
      end

      it 'refunds an integer amount' do
        debit.stub(:refund) do |args|
          expect(args[:amount]).to be_an(Integer)
        end
        subject.complete!(:match_automatic)
      end
    end

    context 'when contributor didn\'t paid payment service fees' do
      before do
        payable_resource.stub(:payment_service_fee_paid_by_user).and_return(false)
      end

      it 'refund contributed value using cents unit, except by fixed operational fee' do
        expect(debit).to receive(:refund).with(hash_including(amount: 10000 - operational_fee))
        subject.complete!(:match_automatic)
      end

      it 'refunds an integer amount' do
        debit.stub(:refund) do |args|
          expect(args[:amount]).to be_an(Integer)
        end
        subject.complete!(:match_automatic)
      end
    end

    context 'with successful refund through Balanced' do
      it 'sets the payable_resource as refunded' do
        expect(payable_resource).to receive(:refund!)
        subject.complete!(:match_automatic)
      end
    end

    context 'with unsuccessful refund through Balanced' do
      before do
        debit.stub(:refund).and_raise { Balanced::Error }
      end

      it 'doesn\'t update state of the payable_resource to refunded' do
        expect(payable_resource).to_not receive(:refund!)
        subject.complete!(:match_automatic) rescue nil
      end
    end
  end
end
