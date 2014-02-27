module Neighborly::Balanced
  class Contributor < ActiveRecord::Base
    self.table_name = :balanced_contributors

    belongs_to :user
  end
end
