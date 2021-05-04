module AjehAdmin
  class Engine < ::Rails::Engine
    isolate_namespace AjehAdmin

    initializer "ajeh_admin.assets.precompile" do |app|
      app.config.assets.precompile += %w(
        ajeh_admin/index.css
        ajeh_admin/index.js
      )
    end

    initializer 'ajeh_admin.action_controller' do |app|
      ActiveSupport.on_load :action_controller_base do
        helper AjehAdmin::ApplicationHelper
      end
    end
  end
end
