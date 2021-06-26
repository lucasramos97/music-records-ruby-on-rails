require 'rails_helper'

RSpec.describe 'Musics API', type: :request do
  let!(:musics) { create_list(:music, 10) }
  let(:music_not_deleted) { musics.select { |m| !m.deleted }.first }
  let(:music_deleted) { musics.select { |m| m.deleted }.first }
  let(:release_date) { Date.current }
  let(:duration) { Time.current }

  describe 'GET /musics' do
    before { get '/musics' }

    it 'returns musics' do
      expect(json).not_to be_empty
      expect(json.size).to eq(10)
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /musics/:id' do

    context 'when music exists' do
      before { get "/musics/#{music_not_deleted.id}" }

      it 'return music by id' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(music_not_deleted.id)
        expect(response).to have_http_status(200)
      end
    end

    context 'when music not exists' do
      before { get "/musics/#{100}" }

      it 'return music by id' do
        expect(json['message']).to eq("Music not found by id: #{100}")
        expect(response).to have_http_status(404)
      end
    end

    context 'when music is deleted' do
      before { get "/musics/#{music_deleted.id}" }

      it 'return music by id' do
        expect(music_deleted.deleted).to eq(true)
        expect(json['message']).to eq("Music not found by id: #{music_deleted.id}")
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST /musics' do

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

  describe 'PUT /musics/:id' do

    context 'when the request has the least amount of valid data' do
      before { put "/musics/#{music_not_deleted.id}", 
        params: { 
          title: 'Title Test', 
          artist: 'Artist Test', 
          release_date: release_date, 
          duration: duration
        }
      }

      it 'update music' do
        expect(json['id']).to eq(music_not_deleted.id)
        expect(json['title']).to eq('Title Test')
        expect(json['artist']).to eq('Artist Test')
        expect(json['release_date']).to eq(release_date.to_s)
        expect(json['duration'].split('T')[1].split('.')[0]).to eq(duration.strftime('%H:%M:%S'))
        expect(json['number_views']).to eq(0)
        expect(json['feat']).to eq(false)
        expect(json['deleted']).to eq(false)
        expect(response).to have_http_status(200)
      end
    end

    context 'when the request is all attributes' do
      before { put "/musics/#{music_not_deleted.id}", 
        params: {
          title: 'Title Test', 
          artist: 'Artist Test', 
          release_date: release_date, 
          duration: duration,
          number_views: 1,
          feat: true
        }
      }

      it 'update music' do
        expect(json['id']).to eq(music_not_deleted.id)
        expect(json['title']).to eq('Title Test')
        expect(json['artist']).to eq('Artist Test')
        expect(json['release_date']).to eq(release_date.to_s)
        expect(json['duration'].split('T')[1].split('.')[0]).to eq(duration.strftime('%H:%M:%S'))
        expect(json['number_views']).to eq(1)
        expect(json['feat']).to eq(true)
        expect(json['deleted']).to eq(false)
        expect(response).to have_http_status(200)
      end
    end

    context 'when the request does not have the title field' do
      before { put "/musics/#{music_not_deleted.id}", 
        params: {
          title: '', 
          artist: 'Artist Test', 
          release_date: release_date, 
          duration: duration
        }
      }

      it 'update music' do
        expect(json['message']).to eq('Title is required!')
        expect(response).to have_http_status(400)
      end
    end

    context 'when the request does not have the artist field' do
      before { put "/musics/#{music_not_deleted.id}", 
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
      before { put "/musics/#{music_not_deleted.id}", 
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
      before { put "/musics/#{music_not_deleted.id}", 
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

    context 'when music not exists' do
      before { put "/musics/#{100}", 
        params: {
          title: 'Title Test', 
          artist: 'Artist Test', 
          release_date: release_date, 
          duration: nil 
        }
      }

      it 'update music' do
        expect(json['message']).to eq("Music not found by id: #{100}")
        expect(response).to have_http_status(404)
      end
    end

    context 'when music is deleted' do
      before { put "/musics/#{music_deleted.id}", 
        params: {
          title: 'Title Test', 
          artist: 'Artist Test', 
          release_date: release_date, 
          duration: duration
        }
      }

      it 'update music' do
        expect(music_deleted.deleted).to eq(true)
        expect(json['message']).to eq("Music not found by id: #{music_deleted.id}")
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'DELETE /musics/:id' do
    
    context 'when music exists' do
      before { delete "/musics/#{music_not_deleted.id}" }

      it 'logical deleted music' do
        expect(json['id']).to eq(music_not_deleted.id)
        expect(json['title']).to eq(music_not_deleted.title)
        expect(json['artist']).to eq(music_not_deleted.artist)
        expect(json['release_date']).to eq(music_not_deleted.release_date.to_s)
        expect(json['duration'].split('T')[1].split('.')[0]).to eq(music_not_deleted.duration.strftime('%H:%M:%S'))
        expect(json['number_views']).to eq(music_not_deleted.number_views)
        expect(json['feat']).to eq(music_not_deleted.feat)
        expect(music_not_deleted.deleted).to eq(false)
        expect(json['deleted']).to eq(true)
        expect(response).to have_http_status(200)
      end
    end

    context 'when music is deleted' do
      before { delete "/musics/#{music_deleted.id}" }

      it 'logical deleted music' do
        expect(music_deleted.deleted).to eq(true)
        expect(json['message']).to eq("Music not found by id: #{music_deleted.id}")
        expect(response).to have_http_status(404)
      end
    end

    context 'when music not exists' do
      before { delete "/musics/#{100}" }

      it 'logical deleted music' do
        expect(json['message']).to eq("Music not found by id: #{100}")
        expect(response).to have_http_status(404)
      end
    end
  end
end