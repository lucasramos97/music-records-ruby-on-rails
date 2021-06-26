require 'rails_helper'

RSpec.describe 'Musics API', type: :request do
  let!(:musics) { create_list(:music, 10) }
  let(:music_id) { musics.first.id }

  describe 'GET /musics' do
    before { get '/musics' }

    it 'returns musics' do
      expect(json).not_to be_empty
      expect(json.size).to eq(10)
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /musics/:id' do
    before { get "/musics/#{music_id}" }

    context 'when music exists' do

      it 'return music by id' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(music_id)
        expect(response).to have_http_status(200)
      end
    end

    context 'when music not exists' do
      let(:music_id) { 100 }

      it 'return music by id' do
        expect(json['message']).to eq("Music not found by id: #{music_id}")
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST /musics' do
    let(:release_date) { Date.current }
    let(:duration) { Time.current }

    context 'when the request has the least amount of valid data' do
      before { post '/musics', 
        params: { 
          title: 'Title Test', 
          artist: 'Artist Test', 
          release_date: release_date, 
          duration: duration
        }
      }

      it 'create music' do
        expect(json['title']).to eq('Title Test')
        expect(json['artist']).to eq('Artist Test')
        expect(json['release_date']).to eq(release_date.to_s)
        expect(json['duration'].split('T')[1].split('.')[0]).to eq(duration.strftime('%H:%M:%S'))
        expect(json['number_views']).to eq(0)
        expect(json['feat']).to eq(false)
        expect(json['deleted']).to eq(false)
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is all attributes' do
      before { post '/musics', 
        params: {
          title: 'Title Test', 
          artist: 'Artist Test', 
          release_date: release_date, 
          duration: duration,
          number_views: 1,
          feat: true
        }
      }

      it 'create music' do
        expect(json['title']).to eq('Title Test')
        expect(json['artist']).to eq('Artist Test')
        expect(json['release_date']).to eq(release_date.to_s)
        expect(json['duration'].split('T')[1].split('.')[0]).to eq(duration.strftime('%H:%M:%S'))
        expect(json['number_views']).to eq(1)
        expect(json['feat']).to eq(true)
        expect(json['deleted']).to eq(false)
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request does not have the title field' do
      before { post '/musics', 
        params: {
          title: '', 
          artist: 'Artist Test', 
          release_date: release_date, 
          duration: duration
        }
      }

      it 'create music' do
        expect(json['message']).to eq('Title is required!')
        expect(response).to have_http_status(400)
      end
    end

    context 'when the request does not have the artist field' do
      before { post '/musics', 
        params: {
          title: 'Title Test', 
          artist: '', 
          release_date: release_date, 
          duration: duration
        }
      }

      it 'create music' do
        expect(json['message']).to eq('Artist is required!')
        expect(response).to have_http_status(400)
      end
    end

    context 'when the request does not have the release date field' do
      before { post '/musics', 
        params: {
          title: 'Title Test', 
          artist: 'Artist Test', 
          release_date: nil, 
          duration: duration
        }
      }

      it 'create music' do
        expect(json['message']).to eq('Release date is required!')
        expect(response).to have_http_status(400)
      end
    end

    context 'when the request does not have the duration field' do
      before { post '/musics', 
        params: {
          title: 'Title Test', 
          artist: 'Artist Test', 
          release_date: release_date, 
          duration: nil 
        }
      }

      it 'create music' do
        expect(json['message']).to eq('Duration is required!')
        expect(response).to have_http_status(400)
      end
    end
  end
end