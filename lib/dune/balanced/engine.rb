module Dune
  module Balanced
    class Engine < ::Rails::Engine
      isolate_namespace Dune::Balanced

      config.autoload_paths += Dir["#{config.root}/app/observers/**/"]

      config.to_prepare do
        ::User.send(:include, Dune::Balanced::User)
      end
    end
  end
end
