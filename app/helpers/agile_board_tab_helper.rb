# Author: Nicolas Meylan
# Date: 09.11.14
# Encoding: UTF-8
# File: agile_board_tab_helper.rb

module AgileBoardTabHelper
  def agile_board_list_button(model)
    content_tag :div, class: 'fancy-list right-content-list' do
      safe_concat model.edit_link(@project)
      safe_concat model.delete_link(@project)
    end
  end


  def tab_content(tab_name)
    content_tag :div, {id: "#{tab_name}-tab", class: 'box', style: 'display:none'} do
      safe_concat send("#{tab_name}_list_header")
      safe_concat send("#{tab_name}_list")
      safe_concat editor_overlay("#{tab_name.singularize}", t(:link_new_status))
    end
  end
end