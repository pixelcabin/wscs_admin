require_relative 'generator_helpers'

module Ajeh::Generators
  class AdminResourcesGenerator < Rails::Generators::NamedBase
    include Rails::Generators::ResourceHelpers
    include Ajeh::GeneratorHelpers

    source_root File.expand_path('../templates/resources', __FILE__)
    argument :attributes, type: :string, default: []
    class_option :orm, default: 'active_record'

    def initialize(args, *options)
      super
      name.replace "admin/#{name}"
      assign_names!(name)
    end

    def create_controller_files
      template "controller.rb", File.join('app/controllers', controller_class_path, "#{controller_file_name}_controller.rb")
    end

    def copy_view_files
      available_views_for('resources').each do |view|
        filename = "#{view}.html.slim"
        template filename, File.join('app/views/admin', controller_file_path, filename)
      end
    end
  end
end
