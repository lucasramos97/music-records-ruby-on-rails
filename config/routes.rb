Rails.application.routes.draw do
  post '/login', to: 'users#login'
  post '/users', to: 'users#create'

  get '/musics/deleted/count', to: 'musics#count_deleted_musics'
  get '/musics/deleted', to: 'musics#index_deleted_musics'
  post '/musics/deleted/restore', to: 'musics#restore_deleted_musics'
  delete '/musics/empty-list', to: 'musics#empty_list'
  delete '/musics/definitive/:id', to: 'musics#definitive_delete_music'
  resources :musics
end
