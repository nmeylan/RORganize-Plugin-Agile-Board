# Author: Nicolas Meylan
# Date: 01.11.14
# Encoding: UTF-8
# File: agile_board_helper.rb

module AgileBoardHelper
  def overlay_form(model, path, method)
    form_for model, url: path, html: {class: 'form', remote: true, method: method} do |f|
      safe_concat content_tag :div, class: 'box', &Proc.new {
        yield f
      }
      safe_concat submit_tag t(:button_submit)
    end
  end

  def agile_board_form_description_field(f)
    content_tag :p do
      safe_concat f.label :description, t(:field_description)
      safe_concat f.text_area :description, {class: 'fancyEditor', rows: 12}
    end
  end

  def required_form_text_field(f, attr_name, label, options = {size: 25})
    content_tag :p do
      safe_concat required_form_label(f, attr_name, label)
      safe_concat f.text_field attr_name, options
    end
  end

  def agile_board_form_color_field(f)
    content_tag :p do
      safe_concat f.label :color, t(:label_color)
      safe_concat color_field_tag f, :color, {size: 26}
    end
  end

  def agile_board_overlay_editor(overlay_id, title, model)
    overlay_tag(overlay_id, 'width:835px') do
      if model
        t = model.new_record? ? title : resize_text(model.caption, 70)
        safe_concat(content_tag(:h1, t))
        safe_concat yield
      end
    end
  end

  def agile_board_select_field(f, attr_name, label, required = false)
    content_tag :div, class: 'autocomplete-combobox' do
      safe_concat(required ? required_form_label(f, attr_name, label) : f.label(attr_name, label))
      safe_concat yield if block_given?
    end
  end

  def split_content?
    @sessions[:display_mode].eql?(:split)
  end

  def unified_content?
    @sessions[:display_mode].eql?(:unified)
  end

end