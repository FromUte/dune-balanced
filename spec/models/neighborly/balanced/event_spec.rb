require 'spec_helper'

describe Neighborly::Balanced::Event do
  let(:contribution)      { double('Contribution', id: 49) }
  let(:notification_type) { 'debit.created' }
  let(:params)            { attributes_for_notification(notification_type) }
  subject { described_class.new(params) }

  describe "validability" do
    before { subject.stub(:contribution).and_return(contribution) }

    context "when contribution exists" do
      context "when its value and payment matches" do
        before do
          contribution.stub(:price_in_cents).and_return(params[:entity][:amount].to_i)
        end

        it { should be_valid }
      end

      context "when value does not match with payment" do
        before do
          contribution.stub(:price_in_cents).and_return((params[:entity][:amount]+1).to_i)
        end

        it { should_not be_valid }
      end
    end

    context "when no contribution does not exist" do
      let(:contribution) { nil }

      it { should_not be_valid }
    end

    context 'with \'bank_account_verification.deposited\'' do
      let(:notification_type) do
        'bank_account_verification.deposited'
      end

      it { should be_valid }
    end
  end

  shared_examples 'storing payment notification' do
    it 'creates a new payment notification' do
      subject.stub(:contribution).and_return(contribution)
      expect(PaymentEngine).to receive(:create_payment_notification).
        with(hash_including(contribution_id: contribution.id))
      subject.save
    end

    it 'stores metadata of event' do
      expect(PaymentEngine).to receive(:create_payment_notification).
        with(hash_including(:extra_data))
      subject.save
    end
  end

  context 'with debit.created params' do
    let(:notification_type) { 'debit.created' }

    it_behaves_like 'storing payment notification'
  end

  context 'with debit.succeeded params' do
    let(:notification_type) { 'debit.succeeded' }

    it_behaves_like 'storing payment notification'
  end

  context 'with bank_account_verification.deposited params' do
    let(:notification_type) { 'bank_account_verification.deposited' }

    it_behaves_like 'storing payment notification'
  end
end
