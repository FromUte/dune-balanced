require 'spec_helper'

describe Neighborly::Balanced::Refund do
  let(:contribution) do
    stub_model(Contribution, payment_id: '1234567890')
  end
  let(:debit) { double('Debit') }
  subject { described_class.new(contribution) }

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
    it 'performs a refund through Balanced API for the given contribution' do
      subject.stub(:debit).and_return(debit)
      expect(debit).to receive(:refund)
      subject.complete!(:match_automatic)
    end
  end
end
