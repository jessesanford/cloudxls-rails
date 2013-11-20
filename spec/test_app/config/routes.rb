TestApp::Application.routes.draw do
  resources :posts do
    collection do
      get "stream"
    end
  end
  get "successful_redirect" => "posts#successful_redirect"
  root to: "posts#index"
end
