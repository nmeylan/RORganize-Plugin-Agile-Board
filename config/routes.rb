AgileBoard::Engine.routes.draw do
  RORganize::Application.routes.draw do
    mount AgileBoard::Engine => '/', as: 'agile_board_plugin'
  end
  scope 'projects/:project_id/' do
    resource :boards, only: [:create, :index, :destroy],  as: 'agile_board', path: 'agile_board' do
      get :index, path: '/(:menu)'
    end
    scope 'agile_board' do
      resources :story_statuses do
        post :change_position
      end
      resource :agile_board_reports, only: [:index], as: 'reports' do
        get :show_sprint, path: '/:sprint_id'
        get :index, path: '/'
      end
      resources :story_points, only: [:edit, :update] do
        collection do
          get :add_points
          post :add_points
        end
      end
      resources :epics
      resources :sprints
      resources :user_stories do
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
