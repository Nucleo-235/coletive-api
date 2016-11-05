Rails.application.routes.draw do
  devise_for :users

  resources :localized_values, only: [ :update ]
  resources :general_contacts, only: [:create], :path => "contato"
  
  # resources :services, only: [ :create, :update, :destroy ]
  # resources :work_contacts, only: [:create], :path => "trabalhe_conosco"
  # resources :general_contacts, only: [:create], :path => "contato"

  scope "(:locale)", locale: /pt-BR|en|es/ do
    root to: 'pages#home'
  end
end
