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
  let!(:musics) { create_list(:music, 10) }
  let!(:deleted_musics) { create_list(:music, 10, deleted: true) }
  let(:music_not_deleted) { musics.first }
  let(:music_not_deleted_id) { music_not_deleted.id }
  let(:music_deleted) { deleted_musics.first }
  let(:music_minimal_attributes) { get_music }

  describe 'GET /musics' do

    context 'no query strings' do
      before { get '/musics' }

      it 'returns musics' do
        expect(json).not_to be_empty
        expect(json['content'].size).to eq(5)
        expect(json['total']).to eq(10)
        expect(response).to have_http_status(200)
      end
    end

    context 'with query strings' do
      before { get '/musics?page=2&size=4' }

      it 'returns musics' do
        expect(json).not_to be_empty
        expect(json['content'].size).to eq(4)
        expect(json['total']).to eq(10)
        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /musics/:id' do
    before { get "/musics/#{music_not_deleted_id}" }

    context 'when music exists' do
      it 'return music by id' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(music_not_deleted.id)
        expect(response).to have_http_status(200)
      end
    end

    context 'when music not exists' do
      let(:music_not_deleted_id) { 100 }

      it 'return music by id' do
        expect(json['message']).to eq("Music not found by id: #{music_not_deleted_id}")
        expect(response).to have_http_status(404)
      end
    end

    context 'when music is deleted' do
      let(:music_not_deleted_id) { music_deleted.id }

      it 'return music by id' do
        expect(music_deleted.deleted).to eq(true)
        expect(json['message']).to eq("Music not found by id: #{music_not_deleted_id}")
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST /musics' do
    before { post '/musics', params: music_minimal_attributes }

    context 'when the request has the least amount of valid data' do
      it 'create music' do
        expect(json['title']).to eq(music_minimal_attributes[:title])
        expect(json['artist']).to eq(music_minimal_attributes[:artist])
        expect(json['release_date']).to eq(music_minimal_attributes[:release_date].to_s)
        expect(json['duration']).to eq(get_duration(music_minimal_attributes[:duration]))
        expect(json['number_views']).to eq(0)
        expect(json['feat']).to eq(false)
        expect(json['deleted']).to eq(false)
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is all attributes' do
      let(:music_minimal_attributes) { { **get_music, number_views: 1, feat: true } }

      it 'create music' do
        expect(json['title']).to eq(music_minimal_attributes[:title])
        expect(json['artist']).to eq(music_minimal_attributes[:artist])
        expect(json['release_date']).to eq(music_minimal_attributes[:release_date].to_s)
        expect(json['duration']).to eq(get_duration(music_minimal_attributes[:duration]))
        expect(json['number_views']).to eq(music_minimal_attributes[:number_views])
        expect(json['feat']).to eq(music_minimal_attributes[:feat])
        expect(json['deleted']).to eq(false)
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
        expect(json['message']).to eq('Release date is required!')
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
  end

  describe 'PUT /musics/:id' do
    before { put "/musics/#{music_not_deleted_id}", params: music_minimal_attributes }

    context 'when the request has the least amount of valid data' do
      it 'update music' do
        expect(json['id']).to eq(music_not_deleted_id)
        expect(json['title']).to eq(music_minimal_attributes[:title])
        expect(json['artist']).to eq(music_minimal_attributes[:artist])
        expect(json['release_date']).to eq(music_minimal_attributes[:release_date].to_s)
        expect(json['duration']).to eq(get_duration(music_minimal_attributes[:duration]))
        expect(json['number_views']).to eq(0)
        expect(json['feat']).to eq(false)
        expect(json['deleted']).to eq(false)
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
        expect(json['deleted']).to eq(false)
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
        expect(json['message']).to eq('Release date is required!')
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
        expect(json['message']).to eq("Music not found by id: #{music_not_deleted_id}")
        expect(response).to have_http_status(404)
      end
    end

    context 'when music is deleted' do
      let(:music_not_deleted_id) { music_deleted.id }

      it 'update music' do
        expect(music_deleted.deleted).to eq(true)
        expect(json['message']).to eq("Music not found by id: #{music_not_deleted_id}")
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'DELETE /musics/:id' do
    before { delete "/musics/#{music_not_deleted_id}" }
    
    context 'when music exists' do
      it 'logical deleted music' do
        expect(json['id']).to eq(music_not_deleted.id)
        expect(json['title']).to eq(music_not_deleted.title)
        expect(json['artist']).to eq(music_not_deleted.artist)
        expect(json['release_date']).to eq(music_not_deleted.release_date.to_s)
        expect(json['duration']).to eq(music_not_deleted.duration)
        expect(json['number_views']).to eq(music_not_deleted.number_views)
        expect(json['feat']).to eq(music_not_deleted.feat)
        expect(music_not_deleted.deleted).to eq(false)
        expect(json['deleted']).to eq(true)
        expect(response).to have_http_status(200)
      end
    end

    context 'when music not exists' do
      let(:music_not_deleted_id) { 100 }

      it 'logical deleted music' do
        expect(json['message']).to eq("Music not found by id: #{music_not_deleted_id}")
        expect(response).to have_http_status(404)
      end
    end

    context 'when music is deleted' do
      let(:music_not_deleted_id) { music_deleted.id }

      it 'logical deleted music' do
        expect(music_deleted.deleted).to eq(true)
        expect(json['message']).to eq("Music not found by id: #{music_not_deleted_id}")
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'GET /musics/deleted/count' do
    before { get '/musics/deleted/count' }
    
    it 'count deleted musics' do
      expect(json).to eq(10)
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /musics/deleted' do

    context 'no query strings' do
      before { get '/musics/deleted' }

      it 'returns deleted musics' do
        expect(json).not_to be_empty
        expect(json['content'].size).to eq(5)
        expect(json['total']).to eq(10)
        expect(response).to have_http_status(200)
      end
    end

    context 'with query strings' do
      before { get '/musics/deleted/?page=2&size=4' }

      it 'returns deleted musics' do
        expect(json).not_to be_empty
        expect(json['content'].size).to eq(4)
        expect(json['total']).to eq(10)
        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'POST musics/deleted/restore' do
    before { post '/musics/deleted/restore', params: deleted_musics, as: :json }
    
    context 'with valid list' do
      it 'restore deleted musics' do
        expect(json).to eq(deleted_musics.length);
        expect(Music.where(deleted: true).count).to eq(0);
        expect(response).to have_http_status(200)
      end
    end

    context 'withot id field in list' do
      let(:deleted_musics) { [ {id: 1}, {id: 2}, {} ] }
      
      it 'restore deleted musics' do
        expect(json['message']).to eq('Id is required to all musics!');
        expect(response).to have_http_status(400)
      end
    end

    context 'with empy list' do
      let(:deleted_musics) { [] }
      
      it 'restore deleted musics' do
        expect(json['message']).to eq('Id is required to all musics!');
        expect(response).to have_http_status(400)
      end
    end

    context 'withot list' do
      let(:deleted_musics) { nil }
      
      it 'restore deleted musics' do
        expect(json['message']).to eq('Id is required to all musics!');
        expect(response).to have_http_status(400)
      end
    end
  end

  describe 'DELETE musics/empty-list' do
    before { delete '/musics/empty-list' }
    
    it 'definitely delete all deleted songs' do
      expect(Music.where(deleted: true).count).to eq(0);
      expect(response).to have_http_status(200)
    end
  end
end