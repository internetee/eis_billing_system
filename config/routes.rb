Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do

      get 'get_invoice_payment_link/show'

      namespace :invoice_generator do
        resources :invoice_generator, only: [:create, :show]
      end

      namespace :callback_handler do
        # post 'callback_handler/callback'
        match '/callback', via: %i[get], to: 'callback_handler#callback', as: :callback
      end

    end
  end
end
