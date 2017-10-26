module AjehAdmin
  module ApplicationHelper
    def ajeh_pagescript
      @pagescript.to_s.camelize(:lower)
    end

    def ajeh_link_to(name = nil, options = nil, html_options = nil, &block)
      html_options, options, name = options, name, block if block_given?

      options ||= {}
      html_options ||= {}

      highlights_on = html_options.delete(:highlights_on)
      selected_class = html_options.delete(:selected_class) { '-selected' }

      html_options = convert_options_to_data_attributes(options, html_options)

      url = url_for(options)
      html_options["href".freeze] ||= url

      if highlights_on
        matches = request.path.match(highlights_on)
        html_options["class".freeze] ||= ""
        html_options["class".freeze] += " #{selected_class}" if matches
      end

      content_tag("a".freeze, name || url, html_options, &block)
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
