Rails.application.routes.draw do
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

      namespace :invoice_generator do
        resources :invoice_generator, only: [:create]
        resources :invoice_number_generator, only: [:create]
        resources :reference_number_generator, only: [:create]
      end

      namespace :callback_handler do
        # post 'callback_handler/callback'
        match '/callback', via: %i[get], to: 'callback_handler#callback', as: :callback
      end

    end
  end
end
