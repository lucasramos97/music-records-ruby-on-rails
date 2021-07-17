Rails.application.routes.draw do
  get '/musics/deleted/count', to: 'musics#count_deleted_musics'
  get '/musics/deleted', to: 'musics#index_deleted_musics'
  post '/musics/deleted/restore', to: 'musics#restore_deleted_musics'
  resources :musics
end
