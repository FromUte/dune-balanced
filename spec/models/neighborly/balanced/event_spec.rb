require 'spec_helper'

describe Neighborly::Balanced::Event do
  let(:user)              { double('User') }
  let(:contributor)       { double('Neighborly::Balanced::Contributor', user: user) }
  let(:notification_type) { 'debit.created' }
  let(:params)            { attributes_for_notification(notification_type) }
  subject { described_class.new(params) }

  it 'gets the type from request params' do
    expect(subject.type).to eql('debit.created')
  end

  it 'gets the entity href from request params' do
    expect(subject.entity_href).to eql('/v1/marketplaces/TEST-MP24PC81sknFKEuhffrbAixq/debits/WD3q99CpFnVTDWMgfXpiC2Mo')
  end

  describe '#resource' do
    context 'when exists a contribution' do
      before do
        Contribution.stub(:find_by).and_return(Contribution.new)
      end

      it 'returns a contribution instance' do
        expect(subject.resource).to be_instance_of(Contribution)
      end

      it 'does not call find_by on Match' do
        expect(Match).not_to receive(:find_by)
        subject.resource
      end
    end

    context 'when does not exists a contribution' do
      before do
        Contribution.stub(:find_by)
      end

      it 'calls find_by on Match' do
        expect(Match).to receive(:find_by)
        subject.resource
      end
    end

    context 'when exists a Match and not a Contribution' do
      before do
        Contribution.stub(:find_by)
        Match.stub(:find_by).and_return(Match.new)
      end

      it 'returns a match instance' do
        expect(subject.resource).to be_instance_of(Match)
      end

      it 'calls find_by on Contribution' do
        expect(Contribution).to receive(:find_by)
        subject.resource
      end
    end
  end

  shared_examples 'eventable' do
    describe 'validability' do
      before { subject.stub(:resource).and_return(resource) }

      context 'when resource exists' do
        context 'when its value and payment matches' do
          before do
            resource.stub(:price_in_cents).and_return(params[:entity][:amount].to_i)
          end

          it { should be_valid }
        end

        context 'when value does not match with payment' do
          before do
            resource.stub(:price_in_cents).and_return((params[:entity][:amount]+1).to_i)
          end

          it { should_not be_valid }
        end
      end

      context 'when no resource does not exist' do
        let(:resource) { nil }

        it { should_not be_valid }
      end

      context 'with \'bank_account_verification.deposited\'' do
        let(:notification_type) do
          'bank_account_verification.deposited'
        end

        it { should be_valid }
      end

      context 'with \'bank_account_verification.verified\'' do
        let(:notification_type) do
          'bank_account_verification.verified'
        end

        it { should be_valid }
      end
    end

    shared_examples 'storing payment notification' do
      it 'creates a new payment notification' do
        subject.stub(:resource).and_return(resource)
        expect(PaymentEngine).to receive(:create_payment_notification).
          with(hash_including(resource_key => resource.id))
        subject.save
      end

      it 'stores metadata of event' do
        expect(PaymentEngine).to receive(:create_payment_notification).
          with(hash_including(:extra_data))
        subject.save
      end

      it 'sets as changed for observers' do
        expect(described_class).to receive(:changed)
        subject.save
      end

      it 'notifies observers' do
        expect(described_class).to receive(:notify_observers).with(subject)
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

      it 'gets its contributor from request params' do
        Configuration.stub(:[]).with(:balanced_marketplace_id).and_return('QWERTY')
        Neighborly::Balanced::Contributor.stub(:find_by).
          with(bank_account_href: '/v1/marketplaces/QWERTY/bank_accounts/BAPGUSU1HHB5kWPcBmnxEq6').
          and_return(contributor)
        expect(subject.contributor).to eql(contributor)
      end

      it 'gets its user from request params' do
        subject.stub(:contributor).and_return(contributor)
        expect(subject.user).to eql(user)
      end
    end

    context 'with debit.canceled params' do
      let(:notification_type) { 'debit.canceled' }

      it_behaves_like 'storing payment notification'
    end

    context 'with bank_account_verification.verified params' do
      let(:notification_type) { 'bank_account_verification.verified' }

      it_behaves_like 'storing payment notification'

      it 'gets its contributor from request params' do
        Configuration.stub(:[]).with(:balanced_marketplace_id).and_return('QWERTY')
        Neighborly::Balanced::Contributor.stub(:find_by).
          with(bank_account_href: '/v1/marketplaces/QWERTY/bank_accounts/BA4xYXDZ7vv62KvVAlgtRIXd').
          and_return(contributor)
        expect(subject.contributor).to eql(contributor)
      end

      it 'gets its user from request params' do
        subject.stub(:contributor).and_return(contributor)
        expect(subject.user).to eql(user)
      end
    end
  end

  context 'when resource is Contribution' do
    let(:resource)          { Contribution.new }
    let(:resource_key)      { :contribution_id }

    it_behaves_like 'eventable'
  end

  context 'when resource is Match' do
    let(:resource)          { Match.new }
    let(:resource_key)      { :match_id }

    it_behaves_like 'eventable'
  end
end
