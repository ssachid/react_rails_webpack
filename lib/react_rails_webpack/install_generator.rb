require 'rails/generators/base'
require 'colorize'

module ReactRailsWebpack
  class InstallGenerator < Rails::Generators::Base
    desc "This generator sets up the files for a rails and react integration using webpack."

    source_root(File.join(File.expand_path(File.dirname(__FILE__))))

    def setup_client_folder
      puts 'Adding client folder...'
      directory 'client'
    end

    def add_root_package_dot_json
      copy_file 'package.json'
    end

    def add_react_helper
      puts 'Adding react_helper.rb...'
      inside 'app' do
        inside 'helpers' do
          copy_file 'react_helper.rb'
        end
      end
    end

    def update_gitignore
      puts 'updating .gitignore...'
      append_to_file '.gitignore' do
        "\n\n\# react_rails_webpack ignores\nclient/node_modules\nclient/environment.json\nnpm-debug.log"
      end
    end

    def set_environment_hostname
      localhost_name = `scutil --get LocalHostName`
      puts "Setting localhost name to #{localhost_name}..."

      gsub_file 'client/environment.json', /<<<LOCALHOST_NAME>>>/ do
        match << localhost_name
      end
    end

    def add_webpack_asset_inclusion
      puts 'Adding asset includes...'
      # Add webpack folder to application asset paths
      app_dot_rb_insert = "    config.assets.paths << \"\#\{config.root\}/app/assets/webpack\"\n"
      insert_into_file(
        'config/application.rb',
        app_dot_rb_insert,
        after: "  class Application < Rails::Application\n"
      ) unless file_already_contains?(app_dot_rb_insert, 'config/application.rb')

      # Add webpack folder require to application.js
      app_dot_js_insert = "//= require_tree ../webpack\n"
      insert_into_file(
        'app/assets/javascripts/application.js',
        app_dot_js_insert,
        after: "//= require_tree .\n"
      ) unless file_already_contains?(app_dot_js_insert, 'app/assets/javascripts/application.js')

      # Add webpack folder require to application.css or .scss or .sass
      if File.exist?('app/assets/stylesheets/application.css')
        insert_into_file(
          'app/assets/stylesheets/application.css',
          "\n *= require_tree ../webpack\n",
          before: ' *= require_self'
        ) unless file_already_contains?("\n *= require_tree ../webpack\n", 'app/assets/stylesheets/application.css')
      end

      ensure_prepended "@import '../webpack/*\n", 'app/assets/stylesheets/application.scss' if File.exist?('app/assets/stylesheets/application.scss')
      ensure_prepended "@import '../webpack/*\n", 'app/assets/stylesheets/application.sass' if File.exist?('app/assets/stylesheets/application.sass')
    end

    def print_reminders
      puts
      puts "-" * `tput cols`.to_i # print line of dashes
      puts
      puts "Done! Now #{"make sure you have node and npm installed".red.bold}, and then #{"run the".red.bold} #{"npm run install".white.bold} #{"and".red.bold} #{"npm run build".white.bold} #{"commands".red.bold} to finish setting up."
      puts
      puts "-" * `tput cols`.to_i # print line of dashes
      puts
    end


    private

    def current_directory_path
      File.join(File.expand_path(File.dirname(__FILE__)))
    end

    def ensure_prepended(line, file)
      return if file_already_contains?(line, file)
      prepend_to_file(file, line)
    end

    def file_missing?(file)
      !File.exist?(file)
    end

    def file_already_contains?(string, file)
      File.readlines(file).join.include?(string)
    end
  end
end
