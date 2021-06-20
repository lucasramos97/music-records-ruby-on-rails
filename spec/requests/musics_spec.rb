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
end