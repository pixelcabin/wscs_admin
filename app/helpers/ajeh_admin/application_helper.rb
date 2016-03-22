module AjehAdmin
  module ApplicationHelper
    def form_submit_link(text='Save')
      content_tag :a, %(<span class="icon">&#xe802;</span><span class="string">#{text}</span>).html_safe, class: 'form-submit'
    end

    def destroy_button(record, name=nil)
      record_name = name || record.class.model_name.singular.humanize
      # path = send(path_sym, record)
      path = url_for([:admin, record])
      button_to "Delete", path, method: :delete, form_class: 'button_to destroy-form', data: { confirm: "Are you sure you want to delete this #{record_name.downcase}?" }
    end
  end
end
