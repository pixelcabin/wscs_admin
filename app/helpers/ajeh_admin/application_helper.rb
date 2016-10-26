module AjehAdmin
  module ApplicationHelper
    def ajeh_pagescript
      @pagescript.to_s.camelize(:lower)
    end

    def ajeh_link_to(text, url=nil, options={})
      html_classes = []
      highlights_on = options.delete(:highlights_on)
      html_classes << options.delete(:class)
      if highlights_on
        matches = request.path.match(highlights_on)
        html_classes << 'selected' if matches
      end
      link_to(text, url, class: html_classes.join(' '), data: { text: text })
    end

    def form_submit_link(text='Save')
      content_tag :a, %(<span class="icon">&#xe802;</span><span class="string">#{text}</span>).html_safe, class: 'form-submit'
    end

    def destroy_button(record, options={})
      if options.is_a?(String)
        name = options
        options = {}
      else
        name = options.fetch(:name) { nil }
      end
      record_name = name || record.class.model_name.singular.humanize
      url = options.fetch(:url) { nil }
      path = url || url_for([:admin, record])
      button_to "Delete", path, method: :delete, form_class: 'button_to destroy-form', data: { confirm: "Are you sure you want to delete this #{record_name.downcase}?" }
    end
  end
end
