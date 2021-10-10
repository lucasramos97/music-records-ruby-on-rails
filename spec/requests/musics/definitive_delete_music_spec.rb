require 'rails_helper'

RSpec.describe 'Definitive Delete Music', type: :request do
  let!(:users) { create_list(:user, 2) }
  let!(:user1) { users[0] }
  let!(:user2) { users[1] }
  let!(:token_user1) { generate_token(user1.id) }
  let!(:token_user2) { generate_token(user2.id) }
  let!(:header_user1) { { 'Authorization': "Bearer #{token_user1}" } }
  let!(:header_user2) { { 'Authorization': "Bearer #{token_user2}" } }
  let!(:no_bearer_header) { { 'Authorization': "Token #{token_user1}" } }

  describe 'DELETE musics/definitive/:id' do
    let!(:deleted_music) { create(:music, deleted: true, user: user1) }
    let!(:deleted_music_id) { deleted_music.id }
    let!(:music) { create(:music, user: user1) }

    before { delete "/musics/definitive/#{deleted_music_id}", params: {}, headers: header_user1 }
    
    context 'definitive delete music' do
      it 'definitive delete music' do

        db_music = Music.find_by(id: deleted_music_id, user: user1)

        expect(db_music).to be_nil
        expect(response).to have_http_status(200)
      end
    end

    context 'definitive delete nonexistent music by id' do
      let(:deleted_music_id) { 100 }

      it 'definitive delete music' do
        expect(json['message']).to eq(Messages::MUSIC_NOT_FOUND)
        expect(response).to have_http_status(404)
      end
    end

    context 'definitive delete non deleted music' do
      let(:deleted_music_id) { music.id }

      it 'definitive delete music' do
        expect(json['message']).to eq(Messages::MUSIC_NOT_FOUND)
        expect(response).to have_http_status(404)
      end
    end

    context 'definitive delete nonexistent music by user' do
      let(:header_user1) { header_user2 }

      it 'definitive delete music' do
        expect(json['message']).to eq(Messages::MUSIC_NOT_FOUND)
        expect(response).to have_http_status(404)
      end
    end

    context 'definitive delete music with invalid token' do
      let(:header_user1) { { 'Authorization': 'Bearer 123' } }
  
      it 'definitive delete music' do
        expect(json['message']).to eq(Messages::INVALID_TOKEN)
        expect(response).to have_http_status(401)
      end
    end
  
    context 'definitive delete music with empty authorization header' do
      let(:header_user1) { { 'Authorization': '' } }
  
      it 'definitive delete music' do
        expect(json['message']).to eq(Messages::HEADER_AUTHORIZATION_NOT_PRESENT)
        expect(response).to have_http_status(401)
      end
    end
  
    context 'definitive delete music with no token header' do
      let(:header_user1) { { 'Authorization': 'Bearer ' } }
  
      it 'definitive delete music' do
        expect(json['message']).to eq(Messages::NO_TOKEN_PROVIDED)
        expect(response).to have_http_status(401)
      end
    end
  
    context 'definitive delete music without authorization header' do
      let(:header_user1) { nil }
  
      it 'definitive delete music' do
        expect(json['message']).to eq(Messages::HEADER_AUTHORIZATION_NOT_PRESENT)
        expect(response).to have_http_status(401)
      end
    end

    context 'definitive delete music without bearer authentication scheme' do
      let(:header_user1) { no_bearer_header }
  
      it 'definitive delete music' do
        expect(json['message']).to eq(Messages::NO_BEARER_AUTHENTICATION_SCHEME)
        expect(response).to have_http_status(401)
      end
    end
  end
end