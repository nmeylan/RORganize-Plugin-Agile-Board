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

  def agile_board_overlay_editor(overlay_id, title, model)
    overlay_tag(overlay_id, 'width:800px') do
      if model
        t = model.new_record? ? title : model.caption
        safe_concat(content_tag(:h1, t))
        safe_concat yield
      end
    end
  end

end