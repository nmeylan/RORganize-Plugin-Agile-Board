module UserStoryDecoratorLink
  # build a link for the change status action.
  # @param [Boolean] fast : should we render the link fast or not. Fast is used when we display a huge amount of link.
  def change_status_link
    change_link('status'.freeze)
  end

  def change_link(change)
    if user_allowed_to?("change_#{change}".freeze)
      #Build a link to the given change.
      "/projects/#{context[:project].slug}/agile_board/user_stories/#{model.to_param}/change_#{change}".freeze
    end
  end

  # build a link for the change sprint action.
  # @param [Boolean] fast : should we render the link fast or not. Fast is used when we display a huge amount of link.
  def change_sprint_link
    change_link('sprint'.freeze)
  end

  # Build a link to detach issues that belongs to the current story.
  def detach_tasks_link
    if user_allowed_to?(:detach_tasks)
      h.link_to h.t(:button_apply),
                h.agile_board_plugin::user_story_detach_tasks_path(context[:project].slug, model.to_param),
                {class: 'button', id: 'user-story-detach-tasks'}
    end
  end

  # Build a new task link.
  def new_task_link
    h.link_to_with_permissions(h.glyph(h.t(:link_new_task), 'plus'),
                               h.agile_board_plugin::user_story_new_task_path(context[:project].slug, model.to_param),
                               context[:project], nil, {class: 'button', remote: true})
  end

  def attach_task_link
    if user_allowed_to?(:attach_tasks)
      h.link_to(h.glyph(h.t(:link_attach_task), 'attachment'), '#',
                {class: 'button', id: 'user-story-attach-tasks'})
    end
  end

  # @param [String] caption : the caption's link.
  # @param [Boolean] fast : do we render a fast link or not?
  # @param [String] action : action name use to call the right method : link_to_"action".
  # @param [Object] params : splat params.
  def generic_link_chooser(caption, fast, action, *params)
    if fast
      send("fast_story_#{action.freeze}_link", context[:project], model.to_param, caption).html_safe
    else
      send("link_to_#{action.freeze}", *params)
    end
  end

  # Render a link to show the current story. If user isn't allowed, only render the given caption.
  # @param [String] caption : the link's caption to display.
  # @param [Boolean] fast : should we render the link fast or not. Fast is used when we display a huge amount of link.
  def show_link(caption, fast = false)
    if user_allowed_to?(:show)
      generic_link_chooser(caption, fast, 'show'.freeze, caption)
    else
      caption
    end
  end

  def link_to_show(caption)
    h.link_to(caption, h.agile_board_plugin::project_user_story_path(context[:project].slug, model.to_param))
  end

  # Render a link to delete the current story. If user isn't allowed, render nothing.
  # @param [Boolean] button : do we render a button or not? Case when we are in the dropdown we don't render a button.
  # @param [Hash] path_params : additional params for the path.
  # @param [Boolean] fast : should we render the link fast or not. Fast is used when we display a huge amount of link.
  def delete_link(button = false, path_params = {}, fast = false)
    if user_allowed_to?(:destroy)
      generic_link_chooser(ApplicationDecorator::DELETE_LINK, fast, 'delete'.freeze, button, path_params)
    end
  end

  # @param [Boolean] button : do we render the button style or not?
  # @param [Hash] path_params : extra path params.
  def link_to_delete(button, path_params)
    h.link_to h.glyph(h.t(:link_delete), 'trashcan'),
              h.agile_board_plugin::project_user_story_path(context[:project].slug, model.to_param, path_params),
              {remote: true, method: :delete, class: "danger danger-dropdown #{button_class(button)}",
               'data-confirm' => h.t(:text_delete_item)}
  end

  # Render a link to edit the current story. If user isn't allowed, render nothing.
  # @param [Boolean] button : do we render a button or not? Case when we are in the dropdown we don't render a button.
  # @param [Hash] path_params : additional params for the path.
  # @param [Boolean] fast : should we render the link fast or not. Fast is used when we display a huge amount of link.
  def edit_link(button = false, path_params = {}, fast = false)
    if user_allowed_to?(:edit)
      generic_link_chooser(ApplicationDecorator::EDIT_LINK, fast, 'edit'.freeze, button, path_params)
    end
  end

  # @param [Boolean] button : do we render the button style or not?
  # @param [Hash] path_params : extra path params.
  def link_to_edit(button, path_params)
    h.link_to(h.glyph(h.t(:link_edit), 'pencil'),
              h.agile_board_plugin::edit_project_user_story_path(context[:project].slug, model.to_param, path_params),
              {remote: true, method: :get, class: "#{button_class(button)}"})
  end

  def search_data_string
    str = "data-searchTitle='#{model.caption}'"
    str += "data-searchTracker='#{self.tracker_caption}'"
    str += "data-searchStatus='#{self.status_caption}'"
    str += "data-searchCategory='#{self.category_caption}'" if self.category_caption
    str += "data-searchEpic='#{self.epic_caption}'" if self.epic_caption
    str
  end


  private
  def user_allowed_to?(action)
    User.current.allowed_to?(action, 'user_stories'.freeze, context[:project])
  end

  def fast_story_show_link(project, story_id, caption)
    "<a href='/projects/#{project.slug}/agile_board/user_stories/#{story_id}'>#{caption}</a>".freeze
  end

  # This link is faster than classical link_to when we have to render over 1k items.
  def fast_story_delete_link(project, story_id, caption)
    "<a class=\"danger danger-dropdown\" data-confirm=\"Are you sure to want to delete this item?\"
        data-method=\"delete\" data-remote=\"true\"
        href=\"/projects/#{project.slug}/agile_board/user_stories/#{story_id}\"
        rel=\"nofollow\">
          <span class=\"octicon-trashcan octicon\"></span>
          #{caption}
    </a>".freeze
  end

  # This link is faster than classical link_to when we have to render over 1k items.
  # To remove the day when rails link_to will come faster.
  def fast_story_edit_link(project, story_id, caption)
    "<a class=\"\" data-method=\"get\" data-remote=\"true\"
        href=\"/projects/#{project.slug}/agile_board/user_stories/#{story_id}/edit\">
          <span class=\"octicon-pencil octicon\"></span>
          #{caption}
    </a>".freeze
  end
end
