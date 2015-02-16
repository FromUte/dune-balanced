module Dune::Balanced::User
  extend ActiveSupport::Concern
  included do
    has_one :balanced_contributor, class_name: 'Dune::Balanced::Contributor'
  end
end
