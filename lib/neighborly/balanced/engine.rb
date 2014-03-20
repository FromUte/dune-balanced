module Neighborly
  module Balanced
    class Engine < ::Rails::Engine
      isolate_namespace Neighborly::Balanced

      initializer 'include_user_concern' do |app|
        ::User.send(:include, Neighborly::Balanced::User)
      end
    end
  end
end
