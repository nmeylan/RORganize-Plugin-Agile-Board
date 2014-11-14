AgileBoard::Engine.routes.draw do
  RORganize::Application.routes.draw do
    mount AgileBoard::Engine => '/', as: 'agile_board_plugin'
    get 'projects/:project_id/agile_board/:action', controller: 'boards'
  end

  scope 'projects/:project_id/' do
    resources :boards, only: [:create, :index, :destroy],  as: 'agile_board'
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
      resources :sprints
      resources :user_stories do
        get :new_task
        post :create_task
        post :detach_tasks
        post :change_sprint
      end

      get :generate_sprint_name, controller: 'sprints'
    end
  end
end
