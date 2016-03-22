<% if namespaced? -%>
require_dependency "<%= namespaced_file_path %>/application_controller"

<% end -%>
class <%= controller_class_name %>Controller < Admin::BaseController
  before_action :set_<%= singular_table_name(false) %>, only: %i(show edit update destroy)

  def index
    @<%= plural_table_name(false) %> = <%= orm_class.all(class_name(false)) %>
  end

  def new
    @<%= singular_table_name(false) %> = <%= orm_class.build(class_name(false)) %>
  end

  def edit
  end

  def create
    @<%= singular_table_name(false) %> = <%= orm_class.build(class_name(false), "#{singular_table_name(false)}_params") %>

    if @<%= orm_instance(singular_table_name(false)).save %>
      redirect_to <%= index_helper %>_url, notice: <%= "'#{human_name} was successfully created.'" %>
    else
      render action: 'new'
    end
  end

  def update
    if @<%= orm_instance(singular_table_name(false)).update("#{singular_table_name(false)}_params") %>
      redirect_to <%= index_helper %>_url, notice: <%= "'#{human_name} was successfully updated.'" %>
    else
      render action: 'edit'
    end
  end

  def destroy
    @<%= orm_instance(singular_table_name(false)).destroy %>
    redirect_to <%= index_helper %>_url, notice: <%= "'#{human_name} was successfully deleted.'" %>
  end

  private

  def set_<%= singular_table_name(false) %>
    @<%= singular_table_name(false) %> = <%= orm_class.find(class_name(false), "params[:id]") %>
  end

  def <%= "#{singular_table_name(false)}_params" %>
    params.require(:<%= singular_table_name(false) %>).permit!
  end
end
