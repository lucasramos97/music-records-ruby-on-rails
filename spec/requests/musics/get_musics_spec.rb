require 'rails_helper'

RSpec.describe 'Get Musics', type: :request do
  let!(:users) { create_list(:user, 2) }
  let!(:user1) { users[0] }
  let!(:user2) { users[1] }
  let!(:token_user1) { generate_token(user1.id) }
  let!(:header_user1) { { 'Authorization': "Bearer #{token_user1}" } }
  let!(:no_bearer_header) { { 'Authorization': "Token_user1 #{token_user1}" } }
  let!(:_0) { create_list(:music, 10, user: user1) }
  let!(:_1) { create_list(:music, 10, user: user2) }
  let!(:_2) { create(:music, deleted: true, user: user1) }

  describe 'GET /musics' do
    before { get '/musics', params: {}, headers: header_user1 }

    context 'get musics with default query params' do
      it 'get musics' do

        db_musics = Music.where(deleted: false, user: user1).order(artist: :asc, title: :asc)
        db_musics_json = convert_music_to_json(db_musics[..4])

        expect(json['content']).to eq(db_musics_json)
        expect(json['content'].length).to eq(5)
        expect(json['total']).to eq(db_musics.length)
        expect(response).to have_http_status(200)
      end
    end

    context 'get musics with explicit query params' do
      before { get '/musics/?page=2&size=4', params: {}, headers: header_user1 }

      it 'get musics' do

        db_musics = Music.where(deleted: false, user: user1).order(artist: :asc, title: :asc)
        db_musics_json = convert_music_to_json(db_musics[4..7])

        expect(json['content']).to eq(db_musics_json)
        expect(json['content'].length).to eq(4)
        expect(json['total']).to eq(db_musics.length)
        expect(response).to have_http_status(200)
      end
    end

    context 'get musics with invalid token' do
      let(:header_user1) { { 'Authorization': 'Bearer 123' } }
  
      it 'get musics' do
        expect(json['message']).to eq(Messages::INVALID_TOKEN)
        expect(response).to have_http_status(401)
      end
    end
  
    context 'get musics with empty authorization header' do
      let(:header_user1) { { 'Authorization': '' } }
  
      it 'get musics' do
        expect(json['message']).to eq(Messages::HEADER_AUTHORIZATION_NOT_PRESENT)
        expect(response).to have_http_status(401)
      end
    end
  
    context 'get musics with no token header' do
      let(:header_user1) { { 'Authorization': 'Bearer ' } }
  
      it 'get musics' do
        expect(json['message']).to eq(Messages::NO_TOKEN_PROVIDED)
        expect(response).to have_http_status(401)
      end
    end
  
    context 'get musics without authorization header' do
      let(:header_user1) { nil }
  
      it 'get musics' do
        expect(json['message']).to eq(Messages::HEADER_AUTHORIZATION_NOT_PRESENT)
        expect(response).to have_http_status(401)
      end
    end

    context 'get musics without bearer authentication scheme' do
      let(:header_user1) { no_bearer_header }
  
      it 'get musics' do
        expect(json['message']).to eq(Messages::NO_BEARER_AUTHENTICATION_SCHEME)
        expect(response).to have_http_status(401)
      end
    end
  end
end