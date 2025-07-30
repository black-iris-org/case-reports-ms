Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :case_reports, only: [:create, :show, :update, :index] do
        get :incident_reports_counts, on: :collection
        delete :destroy_by_datacenter, on: :collection
        member do
          get 'attachments'
        end
        resources :revisions, only: [:index, :show]
        resources :audits, only: [:index]
      end

      resources :users do
        resources :revisions, only: [:index, :show]
      end

      resources :revisions, only: [:index, :show] do
        resources :audits, only: [:index]
      end

      resources :incidents, only: [] do
        resources :case_reports, only: [:index]
      end

      resources :audits, only: [:index, :create]
      resources :audit_reports, only: [:create]
    end

    namespace :v2 do
      resources :case_reports, only: [:create, :show, :update, :index] do
        collection do
          get :updates
        end
        resources :revisions, only: [:index, :show]
        resources :audits, only: [:index]
      end

      resources :incidents, only: [] do
        resources :case_reports, only: [:index]
      end

      resources :audits, only: [:index, :create]
      resources :audit_reports, only: [:create]
    end
  end
end
