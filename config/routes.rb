Rails.application.routes.draw do
  root 'dashboard#index'

  get 'sign_up', to: 'registrations#new'
  post 'sign_up', to: 'registrations#create'
  get 'sign_in', to: 'sessions#new'
  post 'sign_in', to: 'sessions#create', as: 'log_in'
  delete 'logout', to: 'sessions#destroy'

  resources :users, only: [:index, :destroy, :edit, :update, :new] do
    collection do
      post :search
    end
  end

  resources :dashboard do
    collection do
      post :search
    end
  end

  namespace :dashboards do
    resources :invoice_status, only: :update
    resource :invoice_synchronize, only: :update
  end

  namespace :invoice_details do
    resources :payment_references, only: [:show]
    resources :everypay_response, only: [:show]
    resources :directo, only: [:show]
    resources :descriptions, only: [:show]
  end

  resources :everypay, only: [:index] do
    collection do
      post :everypay_data
    end
  end

  resources :references, only: [:index]
  
  namespace :api, defaults: { format: :json } do
    namespace :v1 do

      get 'get_invoice_payment_link/show'

      namespace :directo do
        resources :directo, only: [:create]
      end

      namespace :e_invoice do
        resources :e_invoice, only: [:create]
      end

      namespace :import_data do
        resources :reference_data, only: [:create]
        resources :invoice_data, only: [:create]
      end

      namespace :invoice do
        resource :invoice_synchronize, only: :update
      end

      namespace :invoice_generator do
        resources :invoice_generator, only: [:create]
        resources :invoice_number_generator, only: [:create]
        resources :monthly_invoice_numbers_generator, only: [:create]
        resources :invoice_status, only: [:create]
        resources :reference_number_generator, only: [:create]
        resources :oneoff, only: [:create]
        resources :deposit_prepayment, only: [:create]
        resources :bulk_payment, only: [:create]
      end

      namespace :callback_handler do
        match '/callback', via: %i[get], to: 'callback_handler#callback', as: :callback
      end

    end
  end
end
