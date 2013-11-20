TestApp::Application.routes.draw do
  resources :posts
  get "successful_redirect" => "posts#successful_redirect"
  root to: "posts#index"
end
