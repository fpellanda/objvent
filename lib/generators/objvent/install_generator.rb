module Objvent
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      def copy_initializer
        template "objvent.rb", "config/initializers/objvent.rb"
        template "websocket_rails.rb", "config/initializers/events.rb"
      end

      def show_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end
