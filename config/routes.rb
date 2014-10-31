AgileBoard::Engine.routes.draw do
  RORganize::Application.routes.draw do
    get 'projects/:project_id/agile_board/:action', controller: 'boards'
    mount AgileBoard::Engine => '/', as: 'agile_board_plugin'
  end

  scope 'projects/:project_id/' do
    resources :boards, only: [:create, :index, :destroy],  as: 'agile_board' do
      get :add_points
      post :add_points
    end
    scope 'agile_board' do
      resources :story_statuses do
        post :change_position
      end
      resources :story_points, only: [:edit, :update]
      resources :epics
      resources :sprints
      resources :user_stories
    end
  end
end
