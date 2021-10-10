require 'rails_helper'

RSpec.describe 'Count Deleted Musics', type: :request do
  let!(:users) { create_list(:user, 2) }
  let!(:user1) { users[0] }
  let!(:user2) { users[1] }
  let!(:token_user1) { generate_token(user1.id) }
  let!(:header_user1) { { 'Authorization': "Bearer #{token_user1}" } }
  let!(:no_bearer_header) { { 'Authorization': "Token_user1 #{token_user1}" } }
  let!(:_0) { create_list(:music, 10, deleted: true, user: user1) }
  let!(:_1) { create(:music, user: user1) }
  let!(:_2) { create(:music, deleted: true, user: user2) }

  describe 'GET /musics/deleted/count' do
    before { get '/musics/deleted/count', params: {}, headers: header_user1 }
    
    context 'count deleted musics' do
      it 'count deleted musics' do
        expect(json).to eq(10)
        expect(response).to have_http_status(200)
      end
    end

    context 'count deleted musics with invalid token' do
      let(:header_user1) { { 'Authorization': 'Bearer 123' } }
  
      it 'count deleted musics' do
        expect(json['message']).to eq(Messages::INVALID_TOKEN)
        expect(response).to have_http_status(401)
      end
    end
  
    context 'count deleted musics with empty authorization header' do
      let(:header_user1) { { 'Authorization': '' } }
  
      it 'count deleted musics' do
        expect(json['message']).to eq(Messages::HEADER_AUTHORIZATION_NOT_PRESENT)
        expect(response).to have_http_status(401)
      end
    end
  
    context 'count deleted musics with no token header' do
      let(:header_user1) { { 'Authorization': 'Bearer ' } }
  
      it 'count deleted musics' do
        expect(json['message']).to eq(Messages::NO_TOKEN_PROVIDED)
        expect(response).to have_http_status(401)
      end
    end
  
    context 'count deleted musics without authorization header' do
      let(:header_user1) { nil }
  
      it 'count deleted musics' do
        expect(json['message']).to eq(Messages::HEADER_AUTHORIZATION_NOT_PRESENT)
        expect(response).to have_http_status(401)
      end
    end

    context 'count deleted musics without bearer authentication scheme' do
      let(:header_user1) { no_bearer_header }
  
      it 'count deleted musics' do
        expect(json['message']).to eq(Messages::NO_BEARER_AUTHENTICATION_SCHEME)
        expect(response).to have_http_status(401)
      end
    end
  end
end