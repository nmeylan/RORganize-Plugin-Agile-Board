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
      safe_concat f.text_area :description, {class: 'fancyEditor', rows: 10}
    end
  end

  def required_form_text_field(f, attr_name, label, options = {size: 25, maxLength: 255})
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

  def agile_board_select_field(f, attr_name, label, model, required = false)
    content_tag :div, class: 'autocomplete-combobox' do
      safe_concat(required ? required_form_label(f, attr_name, label) : f.label(attr_name, label))
      if block_given?
        safe_concat yield
      else
        safe_concat f.select "#{attr_name}_id", model.send("#{attr_name}_options"), {include_blank: !required}, {class: "chzn-select#{'-deselect' unless required}  cbb-medium search"}
      end
    end
  end

  def split_content?
    @sessions[:display_mode].eql?(:split)
  end

  def unified_content?
    @sessions[:display_mode].eql?(:unified)
  end

  def fast_story_show_link(project, story_id, caption)
    "<a href='/projects/#{project.slug}/agile_board/user_stories/#{story_id}'>#{caption}</a>"
  end

  # This link is faster than classical link_to when we have to render over 1k items.
  def fast_story_delete_link(project, story_id, caption)
    "<a class=\"danger danger-dropdown\" data-confirm=\"Are you sure to want to delete this item?\" data-method=\"delete\" data-remote=\"true\" href=\"/projects/#{project.slug}/agile_board/user_stories/#{story_id}\" rel=\"nofollow\"><span class=\"octicon-trashcan octicon\"></span>#{caption}</a>"
  end

  # This link is faster than classical link_to when we have to render over 1k items.
  # To remove the day when rails link_to will come faster.
  def fast_story_edit_link(project, story_id, caption)
    "<a class=\"\" data-method=\"get\" data-remote=\"true\" href=\"/projects/#{project.slug}/agile_board/user_stories/#{story_id}/edit\"><span class=\"octicon-pencil octicon\"></span>#{caption}</a>"
  end

end