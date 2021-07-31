require 'rails_helper'

def get_music
  { 
    title: 'Title Test', 
    artist: 'Artist Test', 
    release_date: Date.current, 
    duration: Time.current 
  }
end

def get_duration(time)
  time_plus_one_hour = time + (1*60*60)
  return time_plus_one_hour.strftime('%H:%M:%S')
end

RSpec.describe 'Musics API', type: :request do
  let!(:user1) { create(:user) }
  let!(:user2) { create(:user) }
  let!(:musics_user1) { create_list(:music, 10, user: user1) }
  let!(:musics_user2) { create_list(:music, 10, user: user2) }
  let!(:deleted_musics_user1) { create_list(:music, 10, deleted: true, user: user1) }
  let!(:deleted_musics_user2) { create_list(:music, 10, deleted: true, user: user2) }
  let(:music_not_deleted) { musics_user1.first }
  let(:music_not_deleted_id) { music_not_deleted.id }
  let(:music_deleted) { deleted_musics_user1.first }
  let(:music_minimal_attributes) { { **get_music, user_id: user1.id } }
  let(:music_deleted_id) { music_deleted.id }
  let(:valid_headers_user1) { { 'Authorization': "Bearer #{token_generator(user1.id)}" } }
  let(:valid_headers_user2) { { 'Authorization': "Bearer #{token_generator(user2.id)}" } }
  let(:invalid_headers) { { 'Authorization': 'Bearer 123' } }
  let(:no_bearer_headers) { { 'Authorization': "Token #{token_generator(user1.id)}" } }
  let(:no_token_headers) { { 'Authorization': 'Bearer ' } }

  describe 'GET /musics' do
    before { get '/musics', params: {}, headers: valid_headers_user1 }

    context 'no query strings' do
      it 'returns musics' do
        expect(json).not_to be_empty
        expect(json['content'].size).to eq(5)
        expect(json['total']).to eq(10)
        expect(response).to have_http_status(200)
      end
    end

    context 'with query strings' do
      before { get '/musics?page=2&size=4', params: {}, headers: valid_headers_user1 }

      it 'returns musics' do
        expect(json).not_to be_empty
        expect(json['content'].size).to eq(4)
        expect(json['total']).to eq(10)
        expect(response).to have_http_status(200)
      end
    end

    context 'defer musics by users' do
      let(:valid_headers_user1) { valid_headers_user2 }

      it 'returns musics' do

        ids_music_user1 = Music.where(deleted: false, user_id: user1.id).order(artist: :asc, title: :asc).page(1).per(5).map { |m| m.id }
        ids_music_user2 = json['content'].map { |m| m['id'] }
        match_ids = false
        ids_music_user1.each { |i|
          if ids_music_user2.include?(i)
            match_ids = true
            break
          end
        }

        expect(json).not_to be_empty
        expect(json['content'].size).to eq(5)
        expect(json['total']).to eq(10)
        expect(match_ids).to be_falsey
        expect(response).to have_http_status(200)
      end
    end

    context 'with invalid authorization header' do
      let(:valid_headers_user1) { invalid_headers }

      it 'returns musics' do
        expect(json['message']).to eq('Invalid token!')
        expect(response).to have_http_status(401)
      end
    end

    context 'without authorization header' do
      let(:valid_headers_user1) { nil }

      it 'returns musics' do
        expect(json['message']).to eq('Header Authorization not present!')
        expect(response).to have_http_status(401)
      end
    end

    context 'without Bearer HTTP authentication scheme' do
      let(:valid_headers_user1) { no_bearer_headers }

      it 'returns musics' do
        expect(json['message']).to eq('No Bearer HTTP authentication scheme!')
        expect(response).to have_http_status(401)
      end
    end

    context 'without token value' do
      let(:valid_headers_user1) { no_token_headers }

      it 'returns musics' do
        expect(json['message']).to eq('No token provided!')
        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'GET /musics/:id' do
    before { get "/musics/#{music_not_deleted_id}", params: {}, headers: valid_headers_user1 }

    context 'when music exists' do
      it 'return music by id' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(music_not_deleted_id)
        expect(response).to have_http_status(200)
      end
    end

    context 'when music not exists' do
      let(:music_not_deleted_id) { 100 }

      it 'return music by id' do
        expect(json['message']).to eq('Music not found!')
        expect(response).to have_http_status(404)
      end
    end

    context 'when music is deleted' do
      let(:music_not_deleted_id) { music_deleted.id }

      it 'return music by id' do
        expect(music_deleted.deleted).to eq(true)
        expect(json['message']).to eq('Music not found!')
        expect(response).to have_http_status(404)
      end
    end

    context 'defer music by users' do
      let(:valid_headers_user1) { valid_headers_user2 }

      it 'return music by id' do
        expect(json['message']).to eq('Music not found!')
        expect(response).to have_http_status(404)
      end
    end

    context 'with invalid authorization header' do
      let(:valid_headers_user1) { invalid_headers }

      it 'return music by id' do
        expect(json['message']).to eq('Invalid token!')
        expect(response).to have_http_status(401)
      end
    end

    context 'without authorization header' do
      let(:valid_headers_user1) { nil }

      it 'return music by id' do
        expect(json['message']).to eq('Header Authorization not present!')
        expect(response).to have_http_status(401)
      end
    end

    context 'without Bearer HTTP authentication scheme' do
      let(:valid_headers_user1) { no_bearer_headers }

      it 'return music by id' do
        expect(json['message']).to eq('No Bearer HTTP authentication scheme!')
        expect(response).to have_http_status(401)
      end
    end

    context 'without token value' do
      let(:valid_headers_user1) { no_token_headers }

      it 'return music by id' do
        expect(json['message']).to eq('No token provided!')
        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'POST /musics' do
    before { post '/musics', params: music_minimal_attributes, headers: valid_headers_user1 }

    context 'when the request has the least amount of valid data' do
      it 'create music' do
        expect(json['title']).to eq(music_minimal_attributes[:title])
        expect(json['artist']).to eq(music_minimal_attributes[:artist])
        expect(json['release_date']).to eq(music_minimal_attributes[:release_date].to_s)
        expect(json['duration']).to eq(get_duration(music_minimal_attributes[:duration]))
        expect(json['number_views']).to eq(0)
        expect(json['feat']).to be_falsey
        expect(json['deleted']).to be_falsey
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is all attributes' do
      let(:music_minimal_attributes) { { **get_music, number_views: 1, feat: true, user_id: user1.id } }

      it 'create music' do
        expect(json['title']).to eq(music_minimal_attributes[:title])
        expect(json['artist']).to eq(music_minimal_attributes[:artist])
        expect(json['release_date']).to eq(music_minimal_attributes[:release_date].to_s)
        expect(json['duration']).to eq(get_duration(music_minimal_attributes[:duration]))
        expect(json['number_views']).to eq(music_minimal_attributes[:number_views])
        expect(json['feat']).to eq(music_minimal_attributes[:feat])
        expect(json['deleted']).to be_falsey
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request does not have the title field' do
      let(:music_minimal_attributes) { { **get_music, title: '' } }

      it 'create music' do
        expect(json['message']).to eq('Title is required!')
        expect(response).to have_http_status(400)
      end
    end

    context 'when the request does not have the artist field' do
      let(:music_minimal_attributes) { { **get_music, artist: '' } }

      it 'create music' do
        expect(json['message']).to eq('Artist is required!')
        expect(response).to have_http_status(400)
      end
    end

    context 'when the request does not have the release date field' do
      let(:music_minimal_attributes) { { **get_music, release_date: nil } }

      it 'create music' do
        expect(json['message']).to eq('Release Date is required!')
        expect(response).to have_http_status(400)
      end
    end

    context 'when the request does not have the duration field' do
      let(:music_minimal_attributes) { { **get_music, duration: nil } }

      it 'create music' do
        expect(json['message']).to eq('Duration is required!')
        expect(response).to have_http_status(400)
      end
    end

    context 'with invalid authorization header' do
      let(:valid_headers_user1) { invalid_headers }

      it 'create music' do
        expect(json['message']).to eq('Invalid token!')
        expect(response).to have_http_status(401)
      end
    end

    context 'without authorization header' do
      let(:valid_headers_user1) { nil }

      it 'create music' do
        expect(json['message']).to eq('Header Authorization not present!')
        expect(response).to have_http_status(401)
      end
    end

    context 'without Bearer HTTP authentication scheme' do
      let(:valid_headers_user1) { no_bearer_headers }

      it 'create music' do
        expect(json['message']).to eq('No Bearer HTTP authentication scheme!')
        expect(response).to have_http_status(401)
      end
    end

    context 'without token value' do
      let(:valid_headers_user1) { no_token_headers }

      it 'create music' do
        expect(json['message']).to eq('No token provided!')
        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'PUT /musics/:id' do
    before { put "/musics/#{music_not_deleted_id}", params: music_minimal_attributes, headers: valid_headers_user1 }

    context 'when the request has the least amount of valid data' do
      it 'update music' do
        expect(json['id']).to eq(music_not_deleted_id)
        expect(json['title']).to eq(music_minimal_attributes[:title])
        expect(json['artist']).to eq(music_minimal_attributes[:artist])
        expect(json['release_date']).to eq(music_minimal_attributes[:release_date].to_s)
        expect(json['duration']).to eq(get_duration(music_minimal_attributes[:duration]))
        expect(json['number_views']).to eq(0)
        expect(json['feat']).to be_falsey
        expect(json['deleted']).to be_falsey
        expect(response).to have_http_status(200)
      end
    end

    context 'when the request is all attributes' do
      let(:music_minimal_attributes) { { **get_music, number_views: 1, feat: true } }

      it 'update music' do
        expect(json['id']).to eq(music_not_deleted_id)
        expect(json['title']).to eq(music_minimal_attributes[:title])
        expect(json['artist']).to eq(music_minimal_attributes[:artist])
        expect(json['release_date']).to eq(music_minimal_attributes[:release_date].to_s)
        expect(json['duration']).to eq(get_duration(music_minimal_attributes[:duration]))
        expect(json['number_views']).to eq(music_minimal_attributes[:number_views])
        expect(json['feat']).to eq(music_minimal_attributes[:feat])
        expect(json['deleted']).to be_falsey
        expect(response).to have_http_status(200)
      end
    end

    context 'when the request does not have the title field' do
      let(:music_minimal_attributes) { { **get_music, title: '' } }

      it 'update music' do
        expect(json['message']).to eq('Title is required!')
        expect(response).to have_http_status(400)
      end
    end

    context 'when the request does not have the artist field' do
      let(:music_minimal_attributes) { { **get_music, artist: '' } }

      it 'create music' do
        expect(json['message']).to eq('Artist is required!')
        expect(response).to have_http_status(400)
      end
    end

    context 'when the request does not have the release date field' do
      let(:music_minimal_attributes) { { **get_music, release_date: nil } }

      it 'create music' do
        expect(json['message']).to eq('Release Date is required!')
        expect(response).to have_http_status(400)
      end
    end

    context 'when the request does not have the duration field' do
      let(:music_minimal_attributes) { { **get_music, duration: nil } }

      it 'create music' do
        expect(json['message']).to eq('Duration is required!')
        expect(response).to have_http_status(400)
      end
    end

    context 'when music not exists' do
      let(:music_not_deleted_id) { 100 }

      it 'update music' do
        expect(json['message']).to eq('Music not found!')
        expect(response).to have_http_status(404)
      end
    end

    context 'when music is deleted' do
      let(:music_not_deleted_id) { music_deleted.id }

      it 'update music' do
        expect(music_deleted.deleted).to eq(true)
        expect(json['message']).to eq('Music not found!')
        expect(response).to have_http_status(404)
      end
    end

    context 'defer music by users' do
      let(:valid_headers_user1) { valid_headers_user2 }

      it 'update music' do
        expect(json['message']).to eq('Music not found!')
        expect(response).to have_http_status(404)
      end
    end

    context 'with invalid authorization header' do
      let(:valid_headers_user1) { invalid_headers }

      it 'update music' do
        expect(json['message']).to eq('Invalid token!')
        expect(response).to have_http_status(401)
      end
    end

    context 'without authorization header' do
      let(:valid_headers_user1) { nil }

      it 'update music' do
        expect(json['message']).to eq('Header Authorization not present!')
        expect(response).to have_http_status(401)
      end
    end

    context 'without Bearer HTTP authentication scheme' do
      let(:valid_headers_user1) { no_bearer_headers }

      it 'update music' do
        expect(json['message']).to eq('No Bearer HTTP authentication scheme!')
        expect(response).to have_http_status(401)
      end
    end

    context 'without token value' do
      let(:valid_headers_user1) { no_token_headers }

      it 'update music' do
        expect(json['message']).to eq('No token provided!')
        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'DELETE /musics/:id' do
    before { delete "/musics/#{music_not_deleted_id}", params: {}, headers: valid_headers_user1 }
    
    context 'when music exists' do
      it 'logical deleted music' do
        expect(json['id']).to eq(music_not_deleted.id)
        expect(json['title']).to eq(music_not_deleted.title)
        expect(json['artist']).to eq(music_not_deleted.artist)
        expect(json['release_date']).to eq(music_not_deleted.release_date.to_s)
        expect(json['duration']).to eq(music_not_deleted.duration)
        expect(json['number_views']).to eq(music_not_deleted.number_views)
        expect(json['feat']).to eq(music_not_deleted.feat)
        expect(music_not_deleted.deleted).to be_falsey
        expect(json['deleted']).to eq(true)
        expect(response).to have_http_status(200)
      end
    end

    context 'when music not exists' do
      let(:music_not_deleted_id) { 100 }

      it 'logical deleted music' do
        expect(json['message']).to eq('Music not found!')
        expect(response).to have_http_status(404)
      end
    end

    context 'when music is deleted' do
      let(:music_not_deleted_id) { music_deleted.id }

      it 'logical deleted music' do
        expect(music_deleted.deleted).to eq(true)
        expect(json['message']).to eq('Music not found!')
        expect(response).to have_http_status(404)
      end
    end

    context 'defer music by users' do
      let(:valid_headers_user1) { valid_headers_user2 }

      it 'logical deleted music' do
        expect(json['message']).to eq('Music not found!')
        expect(response).to have_http_status(404)
      end
    end

    context 'with invalid authorization header' do
      let(:valid_headers_user1) { invalid_headers }

      it 'logical deleted music' do
        expect(json['message']).to eq('Invalid token!')
        expect(response).to have_http_status(401)
      end
    end

    context 'without authorization header' do
      let(:valid_headers_user1) { nil }

      it 'logical deleted music' do
        expect(json['message']).to eq('Header Authorization not present!')
        expect(response).to have_http_status(401)
      end
    end

    context 'without Bearer HTTP authentication scheme' do
      let(:valid_headers_user1) { no_bearer_headers }

      it 'logical deleted music' do
        expect(json['message']).to eq('No Bearer HTTP authentication scheme!')
        expect(response).to have_http_status(401)
      end
    end

    context 'without token value' do
      let(:valid_headers_user1) { no_token_headers }

      it 'logical deleted music' do
        expect(json['message']).to eq('No token provided!')
        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'GET /musics/deleted/count' do
    before { get '/musics/deleted/count', params: {}, headers: valid_headers_user1 }
    
    context 'with valid authorization header' do
      it 'count deleted musics' do
        expect(json).to eq(10)
        expect(response).to have_http_status(200)
      end
    end

    context 'defer music by users' do
      let(:valid_headers_user1) { valid_headers_user2 }

      it 'count deleted musics' do
        expect(json).to eq(10)
        expect(response).to have_http_status(200)
      end
    end

    context 'with invalid authorization header' do
      let(:valid_headers_user1) { invalid_headers }

      it 'count deleted musics' do
        expect(json['message']).to eq('Invalid token!')
        expect(response).to have_http_status(401)
      end
    end

    context 'without authorization header' do
      let(:valid_headers_user1) { nil }

      it 'count deleted musics' do
        expect(json['message']).to eq('Header Authorization not present!')
        expect(response).to have_http_status(401)
      end
    end

    context 'without Bearer HTTP authentication scheme' do
      let(:valid_headers_user1) { no_bearer_headers }

      it 'count deleted musics' do
        expect(json['message']).to eq('No Bearer HTTP authentication scheme!')
        expect(response).to have_http_status(401)
      end
    end

    context 'without token value' do
      let(:valid_headers_user1) { no_token_headers }

      it 'count deleted musics' do
        expect(json['message']).to eq('No token provided!')
        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'GET /musics/deleted' do
    before { get '/musics/deleted', params: {}, headers: valid_headers_user1 }

    context 'no query strings' do
      it 'returns deleted musics' do
        expect(json).not_to be_empty
        expect(json['content'].size).to eq(5)
        expect(json['total']).to eq(10)
        expect(response).to have_http_status(200)
      end
    end

    context 'with query strings' do
      before { get '/musics/deleted/?page=2&size=4', params: {}, headers: valid_headers_user1 }

      it 'returns deleted musics' do
        expect(json).not_to be_empty
        expect(json['content'].size).to eq(4)
        expect(json['total']).to eq(10)
        expect(response).to have_http_status(200)
      end
    end

    context 'defer deleted musics by users' do
      let(:valid_headers_user1) { valid_headers_user2 }

      it 'returns deleted musics' do

        ids_deleted_music_user1 = Music.where(deleted: true, user_id: user1.id).order(artist: :asc, title: :asc).page(1).per(5).map { |m| m.id }
        ids_deleted_music_user2 = json['content'].map { |m| m['id'] }
        match_ids = false
        ids_deleted_music_user1.each { |i|
          if ids_deleted_music_user2.include?(i)
            match_ids = true
            break
          end
        }

        expect(json).not_to be_empty
        expect(json['content'].size).to eq(5)
        expect(json['total']).to eq(10)
        expect(match_ids).to be_falsey
        expect(response).to have_http_status(200)
      end
    end

    context 'with invalid authorization header' do
      let(:valid_headers_user1) { invalid_headers }

      it 'returns deleted musics' do
        expect(json['message']).to eq('Invalid token!')
        expect(response).to have_http_status(401)
      end
    end

    context 'without authorization header' do
      let(:valid_headers_user1) { nil }

      it 'returns deleted musics' do
        expect(json['message']).to eq('Header Authorization not present!')
        expect(response).to have_http_status(401)
      end
    end

    context 'without Bearer HTTP authentication scheme' do
      let(:valid_headers_user1) { no_bearer_headers }

      it 'returns deleted musics' do
        expect(json['message']).to eq('No Bearer HTTP authentication scheme!')
        expect(response).to have_http_status(401)
      end
    end

    context 'without token value' do
      let(:valid_headers_user1) { no_token_headers }

      it 'returns deleted musics' do
        expect(json['message']).to eq('No token provided!')
        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'POST musics/deleted/restore' do
    before { post '/musics/deleted/restore', params: deleted_musics_user1, headers: valid_headers_user1, as: :json }
    
    context 'with valid list' do
      it 'restore deleted musics' do
        expect(json).to eq(deleted_musics_user1.length)
        expect(Music.where(deleted: true, user_id: user1.id).count).to eq(0)
        expect(Music.where(deleted: true, user_id: user2.id).count).to eq(10)
        expect(response).to have_http_status(200)
      end
    end

    context 'without id field in list' do
      let(:deleted_musics_user1) { [ {id: 1}, {id: 2}, {} ] }
      
      it 'restore deleted musics' do
        expect(json['message']).to eq('Id is required to all musics!')
        expect(response).to have_http_status(400)
      end
    end

    context 'with empy list' do
      let(:deleted_musics_user1) { [] }
      
      it 'restore deleted musics' do
        expect(json['message']).to eq('Id is required to all musics!')
        expect(response).to have_http_status(400)
      end
    end

    context 'without list' do
      let(:deleted_musics_user1) { nil }
      
      it 'restore deleted musics' do
        expect(json['message']).to eq('Id is required to all musics!')
        expect(response).to have_http_status(400)
      end
    end

    context 'with invalid authorization header' do
      let(:valid_headers_user1) { invalid_headers }

      it 'restore deleted musics' do
        expect(json['message']).to eq('Invalid token!')
        expect(response).to have_http_status(401)
      end
    end

    context 'without authorization header' do
      let(:valid_headers_user1) { nil }

      it 'restore deleted musics' do
        expect(json['message']).to eq('Header Authorization not present!')
        expect(response).to have_http_status(401)
      end
    end

    context 'without Bearer HTTP authentication scheme' do
      let(:valid_headers_user1) { no_bearer_headers }

      it 'restore deleted musics' do
        expect(json['message']).to eq('No Bearer HTTP authentication scheme!')
        expect(response).to have_http_status(401)
      end
    end

    context 'without token value' do
      let(:valid_headers_user1) { no_token_headers }

      it 'restore deleted musics' do
        expect(json['message']).to eq('No token provided!')
        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'DELETE musics/empty-list' do
    before { delete '/musics/empty-list', params: {}, headers: valid_headers_user1 }
    
    context 'with valid authorization header' do
      it 'definitely delete all deleted musics' do
        expect(Music.where(deleted: true, user_id: user1.id).count).to eq(0)
        expect(Music.where(deleted: true, user_id: user2.id).count).to eq(10)
        expect(response).to have_http_status(200)
      end
    end

    context 'with invalid authorization header' do
      let(:valid_headers_user1) { invalid_headers }

      it 'definitely delete all deleted musics' do
        expect(json['message']).to eq('Invalid token!')
        expect(response).to have_http_status(401)
      end
    end

    context 'without authorization header' do
      let(:valid_headers_user1) { nil }

      it 'definitely delete all deleted musics' do
        expect(json['message']).to eq('Header Authorization not present!')
        expect(response).to have_http_status(401)
      end
    end

    context 'without Bearer HTTP authentication scheme' do
      let(:valid_headers_user1) { no_bearer_headers }

      it 'definitely delete all deleted musics' do
        expect(json['message']).to eq('No Bearer HTTP authentication scheme!')
        expect(response).to have_http_status(401)
      end
    end

    context 'without token value' do
      let(:valid_headers_user1) { no_token_headers }

      it 'definitely delete all deleted musics' do
        expect(json['message']).to eq('No token provided!')
        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'DELETE musics/definitive/:id' do
    before { delete "/musics/definitive/#{music_deleted_id}", params: {}, headers: valid_headers_user1 }
    
    context 'when music exists' do
      it 'definitely delete a deleted music' do
        expect(Music.where(id: music_deleted_id, user_id: music_deleted_id).first).to be_nil
        expect(response).to have_http_status(200)
      end
    end

    context 'when music not exists' do
      let(:music_deleted_id) { 100 }

      it 'definitely delete a deleted music' do
        expect(json['message']).to eq('Music not found!')
        expect(response).to have_http_status(404)
      end
    end

    context 'when music is not deleted' do
      let(:music_deleted_id) { music_not_deleted_id }

      it 'definitely delete a deleted music' do
        expect(json['message']).to eq('Music not found!')
        expect(response).to have_http_status(404)
      end
    end

    context 'with invalid authorization header' do
      let(:valid_headers_user1) { invalid_headers }

      it 'definitely delete a deleted music' do
        expect(json['message']).to eq('Invalid token!')
        expect(response).to have_http_status(401)
      end
    end

    context 'without authorization header' do
      let(:valid_headers_user1) { nil }

      it 'definitely delete a deleted music' do
        expect(json['message']).to eq('Header Authorization not present!')
        expect(response).to have_http_status(401)
      end
    end

    context 'without Bearer HTTP authentication scheme' do
      let(:valid_headers_user1) { no_bearer_headers }

      it 'definitely delete a deleted music' do
        expect(json['message']).to eq('No Bearer HTTP authentication scheme!')
        expect(response).to have_http_status(401)
      end
    end

    context 'without token value' do
      let(:valid_headers_user1) { no_token_headers }

      it 'definitely delete a deleted music' do
        expect(json['message']).to eq('No token provided!')
        expect(response).to have_http_status(401)
      end
    end
  end
end