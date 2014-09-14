require "rails/generators"

module Kynort
  module Generators
    class KynortGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      namespace "kynort"

      def make_initializer
        template "initialize_kynort.rb", "config/initializer/kynort.rb"
      end
    end
  end
end