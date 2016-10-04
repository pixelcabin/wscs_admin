require_relative 'generator_helpers'

module Ajeh::Generators
  class AdminResourceGenerator < Rails::Generators::NamedBase
    include Rails::Generators::ResourceHelpers
    include Ajeh::GeneratorHelpers

    # argument :identifier, type: :string, required: true
    argument :attributes, type: :string, default: []
    source_root File.expand_path('../templates/resource', __FILE__)
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
      available_views_for('resource').each do |view|
        filename = "#{view}.html.slim"
        template filename, File.join('app/views/admin', controller_file_path, filename)
      end
    end
  end
end
