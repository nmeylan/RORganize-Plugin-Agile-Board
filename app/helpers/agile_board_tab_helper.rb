# Author: Nicolas Meylan
# Date: 09.11.14
# Encoding: UTF-8
# File: agile_board_tab_helper.rb

module AgileBoardTabHelper
  def agile_board_list_button(model)
    content_tag :span, class: 'fancy-list right-content-list' do
      concat model.edit_link(@project)
      concat model.delete_link(@project)
    end
  end


  def tab_content(tab_name)
    content_tag :div, {id: "#{tab_name}-tab", class: 'box', style: 'display:none'} do
      concat send("#{tab_name}_list_header")
      concat send("#{tab_name}_list")
      concat editor_overlay("#{tab_name.singularize}", t(:link_new_status))
    end
  end
end