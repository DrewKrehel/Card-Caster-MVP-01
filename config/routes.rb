Rails.application.routes.draw do

  # This is a blank app! Pick your first screen, build out the RCAV, and go from there. E.g.:
  # get("/your_first_screen", { :controller => "pages", :action => "first" })

  root "projects#index"

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
  resources :projects
  resources :playing_cards, only: [] do
    patch :flip, on: :member
    patch :move, on: :member
  end

  get "/users" => "users#index", as: :users
  get "/users/:username" => "users#show", as: :user

  get "test_cards", to: "test_cards#index"

end
