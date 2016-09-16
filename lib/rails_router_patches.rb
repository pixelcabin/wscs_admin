module ActionDispatch::Routing
  class Mapper
    def ajeh_admin_page_resource(identifier, path=nil)
        path = identifier.to_s.dasherize if path.blank?
        resource "#{identifier.to_s}_page".to_sym, {
          only: %i(edit update),
          path_names: {
            edit: ''
          }
        }.merge(path: path)
      end

      def ajeh_admin_partial_resource(identifier, path=nil)
        path = identifier.to_s.dasherize if path.blank?
        resource "#{identifier.to_s}_partial".to_sym, {
          only: %i(edit update),
          path_names: {
            edit: ''
          }
        }.merge(path: path)
      end
  end
end
