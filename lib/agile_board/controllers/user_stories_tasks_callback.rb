# Author: Nicolas Meylan
# Date: 18.12.14
# Encoding: UTF-8
# File: user_stories_tasks_callback.rb
module AgileBoard
  module Controllers
    module UserStoriesTasksCallback

      # GET /user_stories/:user_story_id/new_task
      def new_task
        @issue = Issue.new(category_id: @user_story.category_id,
                           tracker_id: @user_story.tracker_id,
                           version_id: @user_story.tasks_version_id,
                           status_id: @user_story.tasks_status_id,
                           project_id: @project.id
        )
        @members = @project.real_members
        agile_board_form_callback(agile_board_plugin::user_story_create_task_path(@project.slug, @user_story.id), :post, 'new_task')
      end

      # POST /user_stories/:user_story_id/create_task
      def create_task
        @issue = Issue.new(issue_params)
        @issue.author = User.current
        @issue.project = @project
        @user_story.issues << @issue
        if @issue.save && @user_story.save
          show_redirection(t(:successful_creation))
        else
          simple_js_callback(false, :create, @issue)
        end
      end

      # POST /user_stories/:user_story_id/detach_tasks
      def detach_tasks
        @user_story.detach_tasks(params[:ids])
        show_redirection(t(:successful_update))
      end


      # POST /user_stories/:user_story_id/attach_tasks
      def attach_tasks
        @user_story.attach_tasks(params[:tasks])
        show_redirection(t(:successful_update))
      end

    end
  end
end