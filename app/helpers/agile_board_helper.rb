# Author: Nicolas Meylan
# Date: 01.11.14
# Encoding: UTF-8
# File: agile_board_helper.rb

module AgileBoardHelper
  include AgileBoardTabHelper
  # @param [String] editor_name : the name of the editor (e.g : epic)
  # @param [String] label : title for the overlay.
  # @param [ActiveRecord::Base] model : record to create or update with the form.
  # @param [String] path : url for the form.
  # @param [Symbol] method : :put or :post.
  def editor_overlay(editor_name, label, model = nil, path = nil, method = nil)
    agile_board_overlay_editor("#{editor_name}-editor-overlay", label, model) do
      send("#{editor_name}_form".to_sym, model, path, method)
    end
  end


  # @param [ActiveRecord::Base] model : record to create or update with the form.
  # @param [String] path : url for the form.
  # @param [Symbol] method : :put or :post.
  def overlay_form(model, path, method)
    rorganize_form_for model, url: path, wrapper: :modal_horizontal_form, html: {class: 'form-horizontal', remote: true, method: method} do |f|
      concat content_tag :div, &Proc.new {
                               yield f
                             }
      concat f.button :submit
    end
  end

  def agile_board_form_color_field(f)
    content_tag :div, class: "form-group required" do
      concat f.label :color, t(:label_color), class: "col-sm-2 control-label"
      concat content_tag :div, color_field_tag(f, :color, class: "form-control"), class: "col-sm-10"
    end
  end

  def agile_board_overlay_editor(overlay_id, title, model)
    overlay_tag(overlay_id, 'width:835px') do
      if model
        t = model.new_record? ? title : resize_text(model.caption, 70)
        concat(content_tag(:h1, t))
        concat yield
      end
    end
  end

  # Build a select field tag.
  # If a block is given only build the label an yield the given block.
  # Else, try to build a select for the given attr_name.
  # @param [FormFor] f : the form.
  # @param [Symbol] attr_name : the attribute name.
  # @param [ActiveRecordBase] model : a decorated(draper) model.
  # @param [Boolean] required : does the field is mandatory?
  def agile_board_select_field(f, attr_name, model, required = false)
    if block_given?
      yield
    else
      f.input attr_name, collection: model.send("#{attr_name}_options"), include_blank: !required,
              my_wrapper_html: {class: "col-sm-8"},
              label_html: {class: "col-sm-4"},
              input_html: {class: "chzn-select#{'-deselect' unless required}  cbb-medium search"}
    end
  end


  def split_content?
    @sessions[:display_mode].eql?(:split)
  end

  def unified_content?
    @sessions[:display_mode].eql?(:unified)
  end

  def span_with_background_style(caption, css_class, color)
    content_tag :span, caption, {class: css_class, style: "#{style_background_color(color)}"}
  end
end