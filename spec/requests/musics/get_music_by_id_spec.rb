require 'rails_helper'

RSpec.describe 'Get Music By Id', type: :request do
  let!(:users) { create_list(:user, 2) }
  let!(:user1) { users[0] }
  let!(:user2) { users[1] }
  let!(:token_user1) { generate_token(user1.id) }
  let!(:token_user2) { generate_token(user2.id) }
  let!(:header_user1) { { 'Authorization': "Bearer #{token_user1}" } }
  let!(:header_user2) { { 'Authorization': "Bearer #{token_user2}" } }
  let!(:no_bearer_header) { { 'Authorization': "Token #{token_user1}" } }
  let!(:music) { create(:music, user: user1) }
  let!(:music_id) { music.id }
  let!(:deleted_music) { create(:music, deleted: true, user: user1) }

  describe 'GET /musics/:id' do
    before { get "/musics/#{music_id}", params: {}, headers: header_user1 }

    context 'get music by id' do
      it 'get music by id' do

        music_json = convert_music_to_json(music)

        expect(json).to eq(music_json)
        expect(response).to have_http_status(200)
      end
    end

    context 'get nonexistent music by id' do
      let(:music_id) { 100 }

      it 'get music by id' do
        expect(json['message']).to eq(Messages::MUSIC_NOT_FOUND)
        expect(response).to have_http_status(404)
      end
    end

    context 'get deleted music by id' do
      let(:music_id) { deleted_music.id }

      it 'get music by id' do
        expect(json['message']).to eq(Messages::MUSIC_NOT_FOUND)
        expect(response).to have_http_status(404)
      end
    end

    context 'get nonexistent music by user' do
      let(:header_user1) { header_user2 }

      it 'get music by id' do
        expect(json['message']).to eq(Messages::MUSIC_NOT_FOUND)
        expect(response).to have_http_status(404)
      end
    end

    context 'get music by id with invalid token' do
      let(:header_user1) { { 'Authorization': 'Bearer 123' } }
  
      it 'get music by id' do
        expect(json['message']).to eq(Messages::INVALID_TOKEN)
        expect(response).to have_http_status(401)
      end
    end
  
    context 'get music by id with empty authorization header' do
      let(:header_user1) { { 'Authorization': '' } }
  
      it 'get music by id' do
        expect(json['message']).to eq(Messages::HEADER_AUTHORIZATION_NOT_PRESENT)
        expect(response).to have_http_status(401)
      end
    end
  
    context 'get music by id with no token header' do
      let(:header_user1) { { 'Authorization': 'Bearer ' } }
  
      it 'get music by id' do
        expect(json['message']).to eq(Messages::NO_TOKEN_PROVIDED)
        expect(response).to have_http_status(401)
      end
    end
  
    context 'get music by id without authorization header' do
      let(:header_user1) { nil }
  
      it 'get music by id' do
        expect(json['message']).to eq(Messages::HEADER_AUTHORIZATION_NOT_PRESENT)
        expect(response).to have_http_status(401)
      end
    end

    context 'get music by id without bearer authentication scheme' do
      let(:header_user1) { no_bearer_header }
  
      it 'get music by id' do
        expect(json['message']).to eq(Messages::NO_BEARER_AUTHENTICATION_SCHEME)
        expect(response).to have_http_status(401)
      end
    end
  end
end