OpenProtocol::Application.routes.draw do
  match 'users/reset_password'         => "users#reset_password"
  match 'users/forgot_password'        => "users#forgot_password"
  resources :users
  resource :user_session
  get  'protocols/new'                => "protocols#new"
  post 'protocols/create'             => "protocols#create"
  get  'protocols/new_step'           => "protocols#new_step"
  get  'protocols/new_author'         => "protocols#new_author"
  get  'protocols/new_reagent'        => "protocols#new_reagent"
  post 'protocols/upload_image'       => "protocols#upload_image"
  post 'protocols/remove_image'       => "protocols#remove_image"
  post 'protocol/:id/vote'            => "protocols#vote"
  match 'protocol/:id/add_to_collection' => "protocols#add_to_collection"
  post 'protocol/:id/create_comment' => "protocols#create_comment"
  post 'protocol/:id/inline_edit'    => "protocols#inline_edit"
  post 'protocol/:id/remove_step'    => "protocols#remove_step"
  post 'protocol/:id/edit_step'      => "protocols#edit_step"
  get  'protocol/:id/*title'         => "protocols#show"
  get  'protocol/:id'                => "protocols#show"

  get  'collections/new'              => "collections#new"
  get  'collections/my'               => "collections#my", :as => "my_collections"
  post 'collection/create'            => "collections#create"
  post 'collections/remove_protocol'  => "collections#remove_protocol"
  post 'collections/rename_category'  => "collections#rename_category"
  post 'collection/:id/inline_edit'  => "collections#inline_edit"
  get  'collection/:id/category_autocomplete' => "collections#category_autocomplete"
  match 'collection/:id/delete'      => "collections#delete"
  get  'collection/:id'              => "collections#show"


  match 'users/forgot_password'        => "users#forgot_password"
  match 'about' => "homepage#about", :as => 'about'
  match 'login' => "user_sessions#new", :as => 'login'
  match 'logout' => "user_sessions#destroy", :as => 'logout'
  match 'register' => "users#new", :as => 'register'

  match 'search' => "search#new", :as => 'search'
  match 'feedback' => "homepage#feedback", :as => 'feedback'
  root :to => "homepage#index"
end
