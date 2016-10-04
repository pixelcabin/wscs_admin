# # Really shouldn't be patching Rails lik this but some
# # idiot made button_to generate an INPUT rather than a BUTTON

module ActionView
  module Helpers
    module UrlHelper
      def button_to(name = nil, options = nil, html_options = nil, &block)
        html_options, options = options, name if block_given?
        options      ||= {}
        html_options ||= {}
        html_options = html_options.stringify_keys

        url    = options.is_a?(String) ? options : url_for(options)
        remote = html_options.delete('remote')
        params = html_options.delete('params')

        method     = html_options.delete('method').to_s
        method_tag = BUTTON_TAG_METHOD_VERBS.include?(method) ? method_tag(method) : ''.html_safe

        form_method  = method == 'get' ? 'get' : 'post'
        form_options = html_options.delete('form') || {}
        form_options[:class] ||= html_options.delete('form_class') || 'button_to'
        form_options[:method] = form_method
        form_options[:action] = url
        form_options[:'data-remote'] = true if remote

        request_token_tag = form_method == 'post' ? token_tag : ''

        html_options = convert_options_to_data_attributes(options, html_options)
        html_options['type'] = 'submit'

        button = if block_given?
          content_tag('button', html_options, &block)
        else
          value = name || url
          content_tag('button', value, html_options)
        end

        inner_tags = method_tag.safe_concat(button).safe_concat(request_token_tag)
        if params
          params.each do |param_name, value|
            inner_tags.safe_concat tag(:input, type: "hidden", name: param_name, value: value.to_param)
          end
        end
        content_tag('form', inner_tags, form_options)
      end

      # def button_to(name, options = {}, html_options = {})
      #   html_options = html_options.stringify_keys
      #   convert_boolean_attributes!(html_options, %w( disabled ))

      #   method_tag = ''
      #   if (method = html_options.delete('method')) && %w{put delete}.include?(method.to_s)
      #     method_tag = tag('input', :type => 'hidden', :name => '_method', :value => method.to_s)
      #   end

      #   form_method = method.to_s == 'get' ? 'get' : 'post'
      #   form_options = html_options.delete('form') || {}
      #   form_options[:class] ||= html_options.delete('form_class') || 'button_to'

      #   remote = html_options.delete('remote')

      #   request_token_tag = ''
      #   if form_method == 'post' && protect_against_forgery?
      #     request_token_tag = tag(:input, :type => "hidden", :name => request_forgery_protection_token.to_s, :value => form_authenticity_token)
      #   end

      #   url = options.is_a?(String) ? options : self.url_for(options)
      #   name ||= url

      #   html_options = convert_options_to_data_attributes(options, html_options)

      #   html_options.merge!("type" => "submit")

      #   form_options.merge!(:method => form_method, :action => url)
      #   form_options.merge!("data-remote" => "true") if remote

      #   "#{tag(:form, form_options, true)}<div>#{method_tag}#{content_tag("button", name, html_options)}#{request_token_tag}</div></form>".html_safe
      # end
    end
  end
end
