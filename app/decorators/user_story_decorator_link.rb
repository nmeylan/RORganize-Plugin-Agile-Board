module UserStoryDecoratorLink

  # build a link for the change status action.
  # @param [Boolean] fast : should we render the link fast or not. Fast is used when we display a huge amount of link.
  def change_status_link
    change_link('status')
  end

  def change_link(change)
    if user_allowed_to?("change_#{change}".to_sym)
      #Build a link to the given change.
      "/projects/#{context[:project].slug}/agile_board/user_stories/#{model.id}/change_#{change}"
    end
  end

  # build a link for the change sprint action.
  # @param [Boolean] fast : should we render the link fast or not. Fast is used when we display a huge amount of link.
  def change_sprint_link
    change_link('sprint')
  end

  # Build a link to detach issues that belongs to the current story.
  def detach_tasks_link
    if user_allowed_to?(:detach_tasks)
      h.link_to h.t(:button_apply),
                h.agile_board_plugin::user_story_detach_tasks_path(context[:project].slug, model.id),
                {class: 'button', id: 'user-story-detach-tasks'}
    end
  end

  # Build a new task link.
  def new_task_link
    h.link_to_with_permissions(h.glyph(h.t(:link_new_task), 'plus'),
                               h.agile_board_plugin::user_story_new_task_path(context[:project].slug, model.id),
                               context[:project], nil, {class: 'button', remote: true})
  end

  # @param [String] caption : the caption's link.
  # @param [Boolean] fast : do we render a fast link or not?
  # @param [String] action : action name use to call the right method : link_to_"action".
  # @param [Object] params : splat params.
  def generic_link_chooser(caption, fast, action, *params)
    if fast
      h.send("fast_story_#{action}_link", context[:project], model.id, caption).html_safe
    else
      send("link_to_#{action}", *params)
    end
  end

  # Render a link to show the current story. If user isn't allowed, only render the given caption.
  # @param [String] caption : the link's caption to display.
  # @param [Boolean] fast : should we render the link fast or not. Fast is used when we display a huge amount of link.
  def show_link(caption, fast = false)
    if user_allowed_to?(:show)
      generic_link_chooser(caption, fast, 'show', caption)
    else
      caption
    end
  end

  def link_to_show(caption)
    h.link_to(caption, h.agile_board_plugin::user_story_path(context[:project].slug, model.id))
  end

  # Render a link to delete the current story. If user isn't allowed, render nothing.
  # @param [Boolean] button : do we render a button or not? Case when we are in the dropdown we don't render a button.
  # @param [Hash] path_params : additional params for the path.
  # @param [Boolean] fast : should we render the link fast or not. Fast is used when we display a huge amount of link.
  def delete_link(button = false, path_params = {}, fast = false)
    if user_allowed_to?(:destroy)
      generic_link_chooser( h.t(:link_delete), fast, 'delete', button, path_params)
    end
  end

  # @param [Boolean] button : do we render the button style or not?
  # @param [Hash] path_params : extra path params.
  def link_to_delete(button, path_params)
    h.link_to h.glyph(h.t(:link_delete), 'trashcan'),
              h.agile_board_plugin::user_story_path(context[:project].slug, model.id, path_params),
              {remote: true, method: :delete, class: "danger danger-dropdown #{button_class(button)}",
               'data-confirm' => h.t(:text_delete_item)}
  end

  # Render a link to edit the current story. If user isn't allowed, render nothing.
  # @param [Boolean] button : do we render a button or not? Case when we are in the dropdown we don't render a button.
  # @param [Hash] path_params : additional params for the path.
  # @param [Boolean] fast : should we render the link fast or not. Fast is used when we display a huge amount of link.
  def edit_link(button = false, path_params = {}, fast = false)
    if user_allowed_to?(:edit)
      generic_link_chooser( h.t(:link_edit), fast, 'edit', button, path_params)
    end
  end

  # @param [Boolean] button : do we render the button style or not?
  # @param [Hash] path_params : extra path params.
  def link_to_edit(button, path_params)
    h.link_to(h.glyph(h.t(:link_edit), 'pencil'),
              h.agile_board_plugin::edit_user_story_path(context[:project].slug, model.id, path_params),
              {remote: true, method: :get, class: "#{button_class(button)}"})
  end

  def search_data_hash
    result = {}
    result['data-search-title'.freeze] = model.caption
    result['data-search-epic'.freeze] = model.epic.caption if model.epic
    result['data-search-category'.freeze] = model.category.caption if model.category
    result['data-search-status'.freeze] = model.status.caption
    result['data-search-tracker'.freeze] = model.tracker.caption
    result
  end


  private
  def user_allowed_to?(action)
    User.current.allowed_to?(action, 'user_stories', context[:project])
  end
end
