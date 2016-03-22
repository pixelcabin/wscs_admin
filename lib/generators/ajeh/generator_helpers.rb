module Ajeh
  module GeneratorHelpers
    private

      def human_name
        name = super
        name.titlecase
      end

      def field_type(type)
        case type
          when :integer              then :number_field
          when :float, :decimal      then :text_field
          when :time                 then :time_select
          when :datetime, :timestamp then :datetime_select
          when :date                 then :date_select
          when :text                 then :expandable_text_field
          when :boolean              then :check_box
          else
            :expandable_text_field
        end
      end

      def model_attributes
        attrs = []
        columns_hash = class_name(false).constantize.columns_hash
        columns_hash.each do |c|
          next if %w(id created_at updated_at).include?(c.first)
          attrs.push c.last
        end
        attrs
      end

      def class_name(namespace=true)
        with_namespace(namespace) do
          (class_path + [file_name]).map!{ |m| m.camelize }.join('::')
        end
      end

      def table_name(namespace=true)
        with_namespace(namespace) do
          base = pluralize_table_names? ? plural_name : singular_name
          (class_path + [base]).join('_')
        end
      end

      def singular_table_name(namespace=true)
        with_namespace(namespace) do
          pluralize_table_names? ? table_name(namespace).singularize : table_name(namespace)
        end
      end

      def plural_table_name(namespace=true)
        with_namespace(namespace) do
          pluralize_table_names? ? table_name(namespace) : table_name(namespace).pluralize
        end
      end

      def with_namespace(namespace, &block)
        original_name = name.dup
        if namespace
          name.replace "admin/#{name}" unless name.include?('admin/')
        else
          name.gsub!('admin/', '')
        end
        assign_names!(name)
        yield
      ensure
        name.replace original_name
      end

      def available_views_for(resource_type)
        if resource_type == 'resource'
          ['edit', '_form']
        else
          ['index', 'edit', 'new', '_form']
        end
      end
  end
end
