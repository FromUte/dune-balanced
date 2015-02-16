require 'spec_helper'

describe Dune::Balanced::Payout do
  subject { described_class.new(project, requestor) }
  before do
    allow(subject).to receive(:financials).and_return(financials)
    subject.stub(:dune_customer).and_return(dune_customer)
    allow(subject).to receive(:order).and_return(order)
    allow(subject).to receive(:credit_platform!)
  end
  let(:project) { double('Project').as_null_object }
  let(:requestor) { double('User').as_null_object }
  let(:dune_customer) do
    double('Dune::Balanced::Customer').as_null_object
  end
  let(:financials) do
    double(
      net_amount:          BigDecimal.new(90),
      payment_service_fee: BigDecimal.new(5),
      platform_fee:        BigDecimal.new(10),
    )
  end
  let(:order) { double('Order', credit_to: nil) }
  let(:bank_account) do
    double('::Balanced::BankAccount', href: '/bank_accounts/foobar')
  end

  describe "completion" do
    before do
      dune_customer.stub(:bank_accounts).
                          and_return(bank_accounts)
    end

    context 'giving a bank account href' do
      before do
        allow(Balanced::BankAccount).to receive(:find)
          .and_return(given_bank_account)
      end
      let(:given_bank_account) { bank_account }
      let(:bank_accounts) { [] }

      it 'credits the amount (in cents) to costumer\'s account' do
        expect(order).to receive(:credit_to).with(hash_including(amount: 9000))
        subject.complete!('/bank_accounts/foobar')
      end
    end

    context "when customer already has a bank account" do
      let(:bank_accounts) { [bank_account] }

      it "credits the amount (in cents) to costumer's account" do
        expect(order).to receive(:credit_to).with(hash_including(amount: 9000))
        subject.complete!
      end

      context 'with successful credit' do
        it 'logs the payout' do
          expect(::Payout).to receive(:create).
            with(hash_including(
              payment_service: 'balanced',
              project_id:      project,
              user_id:         requestor,
              value:           financials.net_amount))
            subject.complete!
        end
      end

      context 'with unsuccessful credit' do
        before do
          allow(order).to receive(:credit_to)
            .and_raise(Balanced::Conflict.new({}))
        end

        it 'skips payout logging' do
          expect(::Payout).to_not receive(:create)
          subject.complete! rescue Balanced::Conflict
        end
      end
    end

    context "when customer has no bank accounts" do
      let(:bank_accounts) { [] }

      it "skips credit call" do
        expect(dune_customer).to_not receive(:credit)
        subject.complete! rescue Dune::Balanced::Error
      end

      it "raises NoBankAccount exception" do
        expect {
          subject.complete!
        }.to raise_error(Dune::Balanced::NoBankAccount)
      end
    end
  end

  describe "customer" do
    it "gets the Customer related to User" do
      updated_customer = double('customer')
      dune_customer.stub(:fetch).and_return(updated_customer)
      expect(subject.customer).to eql(updated_customer)
    end
  end
end
