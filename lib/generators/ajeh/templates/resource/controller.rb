<% if namespaced? -%>
require_dependency "<%= namespaced_file_path %>/application_controller"

<% end -%>
class <%= controller_class_name %>Controller < Admin::BaseController
  before_action :set_<%= singular_table_name(false) %>, only: %i(edit update)

  def edit
  end

  def update
    if @<%= orm_instance(singular_table_name(false)).update("#{singular_table_name(false)}_params") %>
      redirect_to edit_admin_<%= singular_table_name(false) %>_path, notice: <%= "'#{human_name} was successfully updated.'" %>
    else
      render action: 'edit'
    end
  end

  private

  def set_<%= singular_table_name(false) %>
    @<%= singular_table_name(false) %> = <%= class_name(false) %>.get
  end

  def <%= "#{singular_table_name(false)}_params" %>
    params.require(:<%= singular_table_name(false) %>).permit!
  end
end
