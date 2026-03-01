Rails.application.routes.draw do
  # This is a blank app! Pick your first screen, build out the RCAV, and go from there. E.g.:
  # get("/your_first_screen", { :controller => "pages", :action => "first" })

  root "pages#home"

  devise_for :users

  resources :game_sessions do
    resources :session_users, only: [:create, :update, :destroy]
    member do
      post :join_as_player
      post :join_as_observer
      patch :toggle_role
      delete :leave        
    end
  end
  patch "/game_sessions/:game_session_id/playing_cards/shuffle",
      to: "playing_cards#shuffle",
      as: :shuffle_game_session_zone

  resources :projects
  
  resources :playing_cards, only: [] do
    patch :flip, on: :member
    patch :move, on: :member
    patch :rotate, on: :member
  end

  get "pages/home"
  get "/users" => "users#index", as: :users
  get "/users/:username" => "users#show", as: :user

  get "test_cards", to: "test_cards#index"
  

end
