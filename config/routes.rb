Rails.application.routes.draw do
  apipie
  root 'dashboard#index'

  get 'sign_in', to: 'sessions#new'
  delete 'logout', to: 'sessions#destroy'
  resources :white_codes
  resources :invoice_creators, only: %i[new create index show]

  resources :dashboard do
    collection do
      post :search
    end
  end

  resource :errors, only: [:show]

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

  namespace 'auth' do
    resources :invitations, only: %i[show edit create update destroy]
    match '/:provider/callback', via: %i[get post], to: 'tara#callback', as: :tara_callback
    match '/tara/cancel', via: %i[get post delete], to: 'tara#cancel', as: :tara_cancel
    get '/failure', to: 'tara#cancel'
  end
  
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
        resource :update_invoice_data, only: :update
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
        resources :deposit_status, only: [:create]
      end

      namespace :refund do
        resources :auction, only: [:create]
      end

      namespace :callback_handler do
        match '/callback', via: %i[get], to: 'callback_handler#callback', as: :callback
      end

    end
  end
end
