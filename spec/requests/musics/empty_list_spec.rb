require 'rails_helper'

RSpec.describe 'Empty List', type: :request do
  let!(:users) { create_list(:user, 2) }
  let!(:user1) { users[0] }
  let!(:user2) { users[1] }
  let!(:token_user1) { generate_token(user1.id) }
  let!(:header_user1) { { 'Authorization': "Bearer #{token_user1}" } }
  let!(:no_bearer_header) { { 'Authorization': "Token_user1 #{token_user1}" } }
  let!(:expired_token_header) { generate_expired_token(user1.id) }
  let!(:_0) { create_list(:music, 10, deleted: true, user: user1) }
  let!(:_1) { create_list(:music, 10, deleted: true, user: user2) }
  let!(:_2) { create(:music, user: user1) }

  describe 'DELETE musics/empty-list' do
    before { delete '/musics/empty-list', params: {}, headers: header_user1 }
    
    context 'empty list' do
      it 'empty list' do

        db_musics_user1 = Music.where(user: user1)
        db_music_user1 = db_musics_user1[0]

        count_musics_user2 = Music.where(user: user2).count

        expect(json).to eq(10)
        expect(db_musics_user1.length).to eq(1)
        expect(db_music_user1.deleted).to be_falsey
        expect(count_musics_user2).to eq(10)
        expect(response).to have_http_status(200)
      end
    end

    context 'empty list with invalid token' do
      let(:header_user1) { { 'Authorization': 'Bearer 123' } }
  
      it 'empty list' do
        expect(json['message']).to eq(Messages::INVALID_TOKEN)
        expect(response).to have_http_status(401)
      end
    end
  
    context 'empty list with empty authorization header' do
      let(:header_user1) { { 'Authorization': '' } }
  
      it 'empty list' do
        expect(json['message']).to eq(Messages::HEADER_AUTHORIZATION_NOT_PRESENT)
        expect(response).to have_http_status(401)
      end
    end
  
    context 'empty list with no token header' do
      let(:header_user1) { { 'Authorization': 'Bearer ' } }
  
      it 'empty list' do
        expect(json['message']).to eq(Messages::NO_TOKEN_PROVIDED)
        expect(response).to have_http_status(401)
      end
    end
  
    context 'empty list without authorization header' do
      let(:header_user1) { nil }
  
      it 'empty list' do
        expect(json['message']).to eq(Messages::HEADER_AUTHORIZATION_NOT_PRESENT)
        expect(response).to have_http_status(401)
      end
    end

    context 'empty list without bearer authentication scheme' do
      let(:header_user1) { no_bearer_header }
  
      it 'empty list' do
        expect(json['message']).to eq(Messages::NO_BEARER_AUTHENTICATION_SCHEME)
        expect(response).to have_http_status(401)
      end
    end

    context 'empty list with expired token' do
      let(:header_user1) { expired_token_header }
  
      it 'empty list' do
        expect(json['message']).to eq(Messages::TOKEN_EXPIRED)
        expect(response).to have_http_status(401)
      end
    end
  end
end