Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root to: 'games#index'
  resources :games do
    collection do
      get 'rebuild_db'
      get 'destroy_db'
      get 'update_db'
    end
  end

end
