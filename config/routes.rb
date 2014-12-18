AgileBoard::Engine.routes.draw do
  RORganize::Application.routes.draw do
    mount AgileBoard::Engine => '/', as: 'agile_board_plugin'
  end
  scope 'projects/:project_id/' do
    resource :boards, only: [:create, :index, :destroy], as: 'agile_board', path: 'agile_board' do
      resource :agile_board_reports, only: [:index], path: '/report', as: 'reports' do
        get :index, path: '/(:sprint_id)'
        get :health, path: '/:sprint_id/health'
        get :burndown, path: '/:sprint_id/burndown'
        get :burndown_data, path: '/:sprint_id/burndown_data'
        get :show_stories, path: '/:sprint_id/stories'
      end
      constraints(->(req) { req.params[:menu].nil? || ['work', 'plan', 'configuration'].include?(req.params[:menu]) }) do
        get :index, path: '/(:menu)'
      end
      get :tasks_completion
    end
    scope 'agile_board' do
      resources :story_statuses do
        post :change_position
      end

      resources :story_points, only: [:edit, :update] do
        collection do
          get :add_points
          post :add_points
        end
      end
      resources :epics
      resources :sprints do
        put :archive
        put :restore
      end
      resources :user_stories do
        post :attach_tasks
        get :new_task
        post :create_task
        post :detach_tasks
        post :change_sprint
        post :change_status
      end

      get :generate_sprint_name, controller: 'sprints'
    end
  end
end
