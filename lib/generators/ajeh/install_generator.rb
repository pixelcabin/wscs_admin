require_relative 'generator_helpers'

module Ajeh::Generators
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates/install', __FILE__)

    def create_admin_base_controller
      generate 'controller', 'admin/base --skip-routes --no-assets'
      base_controller = File.read find_in_source_paths('base_controller.rb')
      inject_into_class 'app/controllers/admin/base_controller.rb', 'Admin::BaseController', base_controller
    end

    def add_admin_routes
      admin_routes = File.read find_in_source_paths('routes.rb')
      inject_into_file 'config/routes.rb', admin_routes, after: "Rails.application.routes.draw do\n"
    end

    def copy_action_view_monkey_patches_initializer
      action_view_monkey_patches = File.read find_in_source_paths('action_view_monkey_patches.rb')
      initializer 'action_view_monkey_patches.rb', action_view_monkey_patches
    end

    def copy_postgresql_database_tasks_extensions_initializer
      postgresql_database_tasks_extensions = File.read find_in_source_paths('postgresql_database_tasks_extensions.rb')
      initializer 'postgresql_database_tasks_extensions.rb', postgresql_database_tasks_extensions
    end

    def copy_default_theme
      FileUtils.mkdir_p Rails.root.join('app/assets/admin')
      copy_file find_in_source_paths('default_theme.scss'), 'app/assets/admin/ajeh_admin_theme.scss'
    end

    def add_admin_assets_to_assets_pipeline
      append_to_file 'config/initializers/assets.rb', 'Rails.application.config.assets.precompile += %w(admin.js admin.css)'
    end

    def copy_admin_layouts
      copy_file find_in_source_paths('admin.slim'), 'app/views/layouts/admin.slim'
      copy_file find_in_source_paths('admin.slim'), 'app/views/layouts/admin_unauthenticated.slim'
    end

    def create_admin_assets
      FileUtils.touch Rails.root.join('app/assets/javascripts/admin.coffee')
      FileUtils.touch Rails.root.join('app/assets/stylesheets/admin.scss')
    end

    def create_users
      generate 'model', 'user email password_digest'
      rake 'db:migrate'
    end

    def copy_users_and_sessions_files
      directory find_in_source_paths('controllers'), 'app/controllers/admin/'
      directory find_in_source_paths('views'), 'app/views/admin/'
    end

    def update_user_model
      user_model = File.read find_in_source_paths('user.rb')
      inject_into_class 'app/models/user.rb', 'User', user_model
    end
  end
end
