require 'spec_helper'

describe Dune::Balanced::EventsObserver::DebitCanceled do
  let(:contribution) { double('Contribution') }
  let(:event) do
    double('Dune::Balanced::Event', resource: contribution)
  end

  describe '#perform' do
    context 'with \'debit.canceled\' event' do
      before do
        event.stub(:type).and_return('debit.canceled')
      end

      it 'cancel the contribution' do
        expect(contribution).to receive(:cancel!)
        subject.perform(event)
      end
    end

    context 'with other types of events' do
      before do
        event.stub(:type).and_return('debit.created')
      end

      it 'not cancel the contribution' do
        expect(contribution).to_not receive(:cancel)
        subject.perform(event)
      end
    end
  end
end
