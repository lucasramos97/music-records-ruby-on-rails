Rails.application.routes.draw do
  resources :musics
  get '/musics/deleted/count', to: 'musics#count_deleted_musics'
end
