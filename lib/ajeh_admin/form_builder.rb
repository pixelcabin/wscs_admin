module AjehAdmin
  class FormBuilder < ActionView::Helpers::FormBuilder
    delegate :content_tag, :tag, to: :@template

    def field(attribute, options={}, &block)
      t = @template
      object = @object
      object_name = @object_name
      bc = t.capture(&block) if block_given?

      translation_key = "helpers.label.#{object_name}.#{attribute}"
      default_translation = attribute.to_s.humanize.titlecase
      translation = I18n.t(translation_key, default: default_translation)
      translation.gsub!(/\band\b/i, 'and')
      translation.gsub!(/\bpdf\b/i, 'PDF')
      translation.gsub!(/\burl\b/i, 'URL')

      label = options.delete(:label) { nil }
      hint = options.delete(:hint) { nil }
      as = options.delete(:as) { :text_area }
      field_html_class = options.delete(:class)
      required = options.delete(:required) { true }
      input_options = options.delete(:input) { Hash.new }
      input_options[:placeholder] = options.delete(:placeholder) {
        placeholder_translation_key = "helpers.placeholder.#{object_name}.#{attribute}"
        I18n.t(placeholder_translation_key, default: translation)
      }
      input_options[:rows] = 1 if as == :text_area

      html = ''.html_safe
      field_options = {}
      field_options[:id] = [ 'field', object_name, attribute ].join('_')
      field_html_classes = %w(field)
      field_html_classes << field_html_class if field_html_class
      input_wrapper_classes = %w(controls)
      input_wrapper_classes << 'controls-sized' if input_options.has_key?(:size)
      input_wrapper_classes << 'controls-flex' if options.has_key?(:prefix) || input_options.has_key?(:suffix)
      input_wrapper_classes << [ 'controls', as.to_s.dasherize ].join('-')

      attribute_has_errors = begin
        object.errors.include?(attribute)
      rescue
        false
      end

      input_wrapper_options = {}
      input_wrapper_options[:class] = input_wrapper_classes.join(' ')

      label ||= translation
      label = required ? "#{label}*" : label
      if as == :select
        html << label(attribute, label, class: 'field-label')
        choices = input_options.delete(:choices)
        html << t.content_tag(:div, input_wrapper_options) do
          send(as, attribute, choices, input_options)
        end
      elsif as == :check_box
        html << t.content_tag(:div, input_wrapper_options) do
          t.concat send(as, attribute, input_options)
          t.concat t.content_tag(:label, " #{label}", for: [ object_name, attribute ].join('_'))
        end
      elsif as == :wysiwyg
        html << label(attribute, label, class: 'field-label')
        html << t.content_tag(:div, input_wrapper_options) do
          input_options[:data] = {
            wysiwyg: true,
            wysiwyg_config: options[:wysiwyg]
          }
          t.concat send(:text_area, attribute, input_options)
        end
      elsif as == :don
        as = :hidden_field
        input_options[:data] ||= {}
        input_options[:data] = input_options[:data].merge(don: true)
        html << label(attribute, label, class: 'field-label')
        html << t.content_tag(:div, input_wrapper_options) do
          t.concat send(as, attribute, input_options)
        end
      else
        html << label(attribute, label, class: 'field-label')
        html << t.content_tag(:div, input_wrapper_options) do
          t.concat bc if bc
          t.concat t.content_tag(:span, options[:prefix], class: 'controls-prefix') if options.has_key?(:prefix)
          t.concat send(as, attribute, input_options)
          t.concat t.content_tag(:span, options[:suffix], class: 'controls-suffix') if options.has_key?(:suffix)
        end
      end

      hint_translation_key = options.fetch(:hint) { "helpers.hint.#{object_name}.#{attribute}" }
      hint = hint || I18n.t(hint_translation_key, default: '')
      html << t.content_tag(:div, hint.html_safe, class: 'field-hint') if hint.present?

      if attribute_has_errors
        field_html_classes << 'field-with-errors'
        errors_html = ''.html_safe
        object.errors.full_messages_for(attribute).each do |message|
          errors_html << t.content_tag(:li, message)
        end
        errors_html = t.content_tag(:ul, errors_html, class: 'field-errors')
        field_options[:class] = field_html_classes.join(' ')
        html = t.content_tag(:div, html, field_options)
        html << errors_html
      else
        field_options[:class] = field_html_classes.join(' ')
        t.content_tag(:div, html, field_options)
      end
    end

    def expandable_text_field(method, options={})
      options.merge!(rows: 1)
      text_field_with_class('expandable', method, options)
    end

    def radio_buttons(method, choices, options={})
      labels = choices.map do |k, v|
        label = '<label>'
        label += radio_button(:status, v).to_s
        label += k
        label += '</label>'
      end
      labels.join('').html_safe
    end

    private

      def text_field_with_class(cssClass, method, options={})
        if options[:class]
          options[:class] += " #{cssClass}"
        else
          options[:class] = cssClass
        end
        text_area(method, options)
      end
  end
end
