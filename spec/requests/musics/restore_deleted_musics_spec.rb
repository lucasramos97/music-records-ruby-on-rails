require 'rails_helper'

RSpec.describe 'Restore Deleted Musics', type: :request do
  let!(:users) { create_list(:user, 2) }
  let!(:user1) { users[0] }
  let!(:user2) { users[1] }
  let!(:token_user1) { generate_token(user1.id) }
  let!(:token_user2) { generate_token(user2.id) }
  let!(:header_user1) { { 'Authorization': "Bearer #{token_user1}" } }
  let!(:header_user2) { { 'Authorization': "Bearer #{token_user2}" } }
  let!(:no_bearer_header) { { 'Authorization': "Token_user1 #{token_user1}" } }

  describe 'POST musics/deleted/restore' do
    let!(:deleted_musics) { create_list(:music, 10, deleted: true, user: user1) }
    let!(:musics) { create_list(:music, 1, user: user1) }
    let!(:_0) { create_list(:music, 10, deleted: true, user: user2) }
    let!(:musics_params) { deleted_musics }

    before { post '/musics/deleted/restore', params: musics_params, headers: header_user1, as: :json }
    
    context 'restore deleted musics' do
      it 'restore deleted musics' do

        count_musics_user1 = Music.where(deleted: false, user: user1).count
        count_deleted_musics_user2 = Music.where(deleted: true, user: user2).count

        expect(json).to eq(10)
        expect(count_musics_user1).to eq(11)
        expect(count_deleted_musics_user2).to eq(10)
        expect(response).to have_http_status(200)
      end
    end

    context 'restore deleted nonexistent musics by id' do
      let(:musics_params) { 
        deleted_musics.each { |m|
          if m.id == 1 then m.id = 1000 end 
        }
      }

      it 'restore deleted musics' do

        count_musics_user1 = Music.where(deleted: false, user: user1).count
        count_deleted_musics_user2 = Music.where(deleted: true, user: user2).count

        expect(json).to eq(9)
        expect(count_musics_user1).to eq(10)
        expect(count_deleted_musics_user2).to eq(10)
        expect(response).to have_http_status(200)
      end
    end

    context 'restore deleted non deleted musics' do
      let(:musics_params) { musics }

      it 'restore deleted musics' do

        db_musics_user1 = Music.where(user: user1)
        contain_not_deleted = false
        db_musics_user1.each do |m|
          if not m.deleted
            contain_not_deleted = true
            break
          end
        end

        count_deleted_musics_user2 = Music.where(deleted: true, user: user2).count

        expect(json).to eq(0)
        expect(db_musics_user1.length).to eq(11)
        expect(contain_not_deleted).to be_truthy
        expect(count_deleted_musics_user2).to eq(10)
        expect(response).to have_http_status(200)
      end
    end

    context 'restore deleted nonexistent musics by user' do
      let(:header_user1) { header_user2 }

      it 'restore deleted musics' do

        count_musics_user1 = Music.where(deleted: false, user: user1).count
        count_deleted_musics_user2 = Music.where(deleted: true, user: user2).count

        expect(json).to eq(0)
        expect(count_musics_user1).to eq(1)
        expect(count_deleted_musics_user2).to eq(10)
        expect(response).to have_http_status(200)
      end
    end

    context 'restore deleted musics without id field' do
      let(:deleted_musics) { [{none: 1}, {id: 2}, {id: 3}] }

      it 'restore deleted musics' do
        expect(json['message']).to eq(Messages::ID_IS_REQUIRED)
        expect(response).to have_http_status(400)
      end
    end

    context 'restore deleted musics with invalid token' do
      let(:header_user1) { { 'Authorization': 'Bearer 123' } }
  
      it 'restore deleted musics' do
        expect(json['message']).to eq(Messages::INVALID_TOKEN)
        expect(response).to have_http_status(401)
      end
    end
  
    context 'restore deleted musics with empty authorization header' do
      let(:header_user1) { { 'Authorization': '' } }
  
      it 'restore deleted musics' do
        expect(json['message']).to eq(Messages::HEADER_AUTHORIZATION_NOT_PRESENT)
        expect(response).to have_http_status(401)
      end
    end
  
    context 'restore deleted musics with no token header' do
      let(:header_user1) { { 'Authorization': 'Bearer ' } }
  
      it 'restore deleted musics' do
        expect(json['message']).to eq(Messages::NO_TOKEN_PROVIDED)
        expect(response).to have_http_status(401)
      end
    end
  
    context 'restore deleted musics without authorization header' do
      let(:header_user1) { nil }
  
      it 'restore deleted musics' do
        expect(json['message']).to eq(Messages::HEADER_AUTHORIZATION_NOT_PRESENT)
        expect(response).to have_http_status(401)
      end
    end

    context 'restore deleted musics without bearer authentication scheme' do
      let(:header_user1) { no_bearer_header }
  
      it 'restore deleted musics' do
        expect(json['message']).to eq(Messages::NO_BEARER_AUTHENTICATION_SCHEME)
        expect(response).to have_http_status(401)
      end
    end
  end
end