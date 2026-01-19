Rails.application.routes.draw do
  resources :session_users
  resources :game_sessions
  # This is a blank app! Pick your first screen, build out the RCAV, and go from there. E.g.:
  # get("/your_first_screen", { :controller => "pages", :action => "first" })
  
  root "projects#index"
  
  devise_for :users

  resources :game_sessions, controller: "sessions"
  resources :projects

  get "/users" => "users#index", as: :users
  get "/users/:username" => "users#show", as: :user
 

end

