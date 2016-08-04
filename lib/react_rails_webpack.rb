require 'react_rails_webpack/version'

module ReactRailsWebpack
  class ReactRailsWebpackRailtie < Rails::Railtie
    generators do
      require_relative 'react_rails_webpack/install_generator'
      require_relative 'react_rails_webpack/create_example_page_generator'
    end
  end
end
