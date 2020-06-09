Rails.application.routes.draw do
  root 'static_pages#top'
  get '/signup', to: 'users#new'

  # ログイン機能
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  # memberはメンバールーティング（photos/:id/previewのようにidを伴うパス）を追加するときに使う。
  # memberブロックをリソースブロック(resources :~~ do)の中に1つ追加する。追加したブロック内にメンバルーティングを記述する。
  # 参照:https://qiita.com/senou/items/f1491e53450cb347606b
  resources :users do
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
    end
  end
end