AgileBoard::Engine.routes.draw do
  RORganize::Application.routes.draw do
    get 'projects/:project_id/agile_board/:action', controller: 'boards'
    mount AgileBoard::Engine => '/', as: 'agile_boards_route'

  end
  scope 'projects/:project_id/' do
    resources :boards, as: 'agile_board'
  end
end
