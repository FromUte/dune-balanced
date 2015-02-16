module Dune::Balanced
  class Order < ActiveRecord::Base
    self.table_name = :dune_balanced_orders

    belongs_to :project

    validates :project, :href, presence: true
  end
end
