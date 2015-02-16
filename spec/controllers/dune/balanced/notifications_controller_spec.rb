require 'spec_helper'

describe Dune::Balanced::NotificationsController do
  routes { Dune::Balanced::Engine.routes }
  let(:event) { double('Event') }

  shared_examples 'create action' do
    it 'saves a new event' do
      expect_any_instance_of(Dune::Balanced::Event).to receive(:save)
      post :create, params
    end

    context 'with valid event' do
      before do
        Dune::Balanced::Event.any_instance.stub(:valid?).and_return(true)
      end

      it 'responds with 200 http status' do
        post :create, params
        expect(response.status).to eql(200)
      end
    end

    context 'with invalid event' do
      before do
        Dune::Balanced::Event.any_instance.stub(:valid?).and_return(false)
      end

      it 'responds with 400 http status' do
        post :create, params
        expect(response.status).to eql(400)
      end
    end
  end

  describe 'POST \'create\'' do
    context 'with debit.created notification' do
      let(:params) do
        attributes_for_notification('debit.created')
      end

      it_behaves_like 'create action'
    end

    context 'with debit.succeeded notification' do
      let(:params) do
        attributes_for_notification('debit.succeeded')
      end

      it_behaves_like 'create action'
    end

    context 'with bank_account_verification.deposited notification' do
      let(:params) do
        attributes_for_notification('bank_account_verification.deposited')
      end

      it_behaves_like 'create action'
    end
  end
end
