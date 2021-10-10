require 'rails_helper'

RSpec.describe 'Delete Music', type: :request do
  let!(:users) { create_list(:user, 2) }
  let!(:user1) { users[0] }
  let!(:user2) { users[1] }
  let!(:token_user1) { generate_token(user1.id) }
  let!(:token_user2) { generate_token(user2.id) }
  let!(:header_user1) { { 'Authorization': "Bearer #{token_user1}" } }
  let!(:header_user2) { { 'Authorization': "Bearer #{token_user2}" } }
  let!(:no_bearer_header) { { 'Authorization': "Token #{token_user1}" } }
  let!(:expired_token_header) { generate_expired_token(user1.id) }

  describe 'DELETE /musics/:id' do
    let!(:music) { create(:music, user: user1) }
    let!(:music_id) { music.id }
    let!(:deleted_music) { create(:music, deleted: true, user: user1) }

    before { delete "/musics/#{music_id}", params: {}, headers: header_user1 }
    
    context 'delete music' do
      it 'delete music' do

        music_json = convert_music_to_json(music)

        db_music = Music.find_by(id: music.id, user: user1)
        db_music_json = convert_music_to_json(db_music)

        valid_created_at = all_equals(
          music_json['created_at'], 
          db_music_json['created_at'], 
          json['created_at']
        )

        expect(json).to eq(db_music_json)
        expect(json['deleted']).to be_nil
        expect(json['user']).to be_nil
        expect(db_music.deleted).to be_truthy
        expect(json['created_at']).not_to be_nil
        expect(json['updated_at']).not_to be_nil
        expect(valid_created_at).to be_truthy
        expect(json['updated_at']).to eq(db_music_json['updated_at'])
        expect(json['updated_at']).not_to eq(music_json['updated_at'])
        expect(response).to have_http_status(200)
      end
    end

    context 'delete nonexistent music by id' do
      let(:music_id) { 100 }

      it 'delete music' do
        expect(json['message']).to eq(Messages::MUSIC_NOT_FOUND)
        expect(response).to have_http_status(404)
      end
    end

    context 'delete deleted music' do
      let(:music_id) { deleted_music.id }

      it 'delete music' do
        expect(json['message']).to eq(Messages::MUSIC_NOT_FOUND)
        expect(response).to have_http_status(404)
      end
    end

    context 'delete nonexistent music by user' do
      let(:header_user1) { header_user2 }

      it 'delete music' do
        expect(json['message']).to eq(Messages::MUSIC_NOT_FOUND)
        expect(response).to have_http_status(404)
      end
    end

    context 'delete music with invalid token' do
      let(:header_user1) { { 'Authorization': 'Bearer 123' } }
  
      it 'delete music' do
        expect(json['message']).to eq(Messages::INVALID_TOKEN)
        expect(response).to have_http_status(401)
      end
    end
  
    context 'delete music with empty authorization header' do
      let(:header_user1) { { 'Authorization': '' } }
  
      it 'delete music' do
        expect(json['message']).to eq(Messages::HEADER_AUTHORIZATION_NOT_PRESENT)
        expect(response).to have_http_status(401)
      end
    end
  
    context 'delete music with no token header' do
      let(:header_user1) { { 'Authorization': 'Bearer ' } }
  
      it 'delete music' do
        expect(json['message']).to eq(Messages::NO_TOKEN_PROVIDED)
        expect(response).to have_http_status(401)
      end
    end
  
    context 'delete music without authorization header' do
      let(:header_user1) { nil }
  
      it 'delete music' do
        expect(json['message']).to eq(Messages::HEADER_AUTHORIZATION_NOT_PRESENT)
        expect(response).to have_http_status(401)
      end
    end

    context 'delete music without bearer authentication scheme' do
      let(:header_user1) { no_bearer_header }
  
      it 'delete music' do
        expect(json['message']).to eq(Messages::NO_BEARER_AUTHENTICATION_SCHEME)
        expect(response).to have_http_status(401)
      end
    end

    context 'delete music with expired token' do
      let(:header_user1) { expired_token_header }
  
      it 'delete music' do
        expect(json['message']).to eq(Messages::TOKEN_EXPIRED)
        expect(response).to have_http_status(401)
      end
    end
  end
end