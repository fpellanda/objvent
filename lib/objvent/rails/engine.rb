module Objvent
  module Rails
    class Engine < ::Rails::Engine

      config.autoload_paths += [File.expand_path("../../lib", __FILE__)]
      

    end
  end
end
