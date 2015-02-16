require 'spec_helper'

describe Dune::Balanced::Order do
  describe 'validations' do
    it { should validate_presence_of(:project) }
    it { should validate_presence_of(:href) }
  end
end
