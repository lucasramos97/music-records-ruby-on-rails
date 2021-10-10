require 'rails_helper'

RSpec.describe 'Put Music', type: :request do
  let!(:users) { create_list(:user, 2) }
  let!(:user1) { users[0] }
  let!(:user2) { users[1] }
  let!(:token_user1) { generate_token(user1.id) }
  let!(:token_user2) { generate_token(user2.id) }
  let!(:header_user1) { { 'Authorization': "Bearer #{token_user1}" } }
  let!(:header_user2) { { 'Authorization': "Bearer #{token_user2}" } }
  let!(:no_bearer_header) { { 'Authorization': "Token_user1 #{token_user1}" } }
  let!(:expired_token_header) { generate_expired_token(user1.id) }
  let!(:music) { create(:music, user: user1) }
  let!(:deleted_music) { create(:music, deleted: true, user: user1) }
  
  describe 'PUT /musics/:id' do
    let!(:all_attributes_music) {
      {
        title: "#{music.title} Test",
        artist: "#{music.artist} Test",
        release_date: Date.today.to_s,
        duration: Time.new.strftime('%H:%M:%S'),
        number_views: music.number_views + 1,
        feat: !music.feat,
      }
    }
    let!(:minimal_attributes_music) {
      {
        title: "#{music.title} Test",
        artist: "#{music.artist} Test",
        release_date: Date.today.to_s,
        duration: Time.new.strftime('%H:%M:%S'),
      }
    }
    let!(:music_id) { music.id }
    let!(:music_params) { all_attributes_music }

    before { put "/musics/#{music_id}", params: music_params, headers: header_user1 }

    context 'put all attributes music' do
      it 'put music' do
    
        music_json = convert_music_to_json(music)
    
        db_music = Music.find_by(id: json['id'], user: user1)
        db_music_json = convert_music_to_json(db_music)
    
        valid_title = all_equals(
          all_attributes_music[:title], 
          db_music_json['title'], 
          json['title']
        )
    
        valid_artist = all_equals(
          all_attributes_music[:artist], 
          db_music_json['artist'], 
          json['artist']
        )
    
        valid_release_date = all_equals(
          all_attributes_music[:release_date], 
          db_music_json['release_date'], 
          json['release_date']
        )
    
        valid_duration = all_equals(
          all_attributes_music[:duration], 
          db_music_json['duration'], 
          json['duration']
        )
    
        valid_number_views = all_equals(
          all_attributes_music[:number_views], 
          db_music_json['number_views'], 
          json['number_views']
        )
    
        valid_feat = all_equals(
          all_attributes_music[:feat], 
          db_music_json['feat'], 
          json['feat']
        )
    
        valid_created_at = all_equals(
          music_json['created_at'], 
          db_music_json['created_at'], 
          json['created_at']
        )
    
        expect(json['id']).to eq(music_json['id'])
        expect(valid_title).to be_truthy
        expect(json['title']).to_not eq(music_json['title'])
        expect(valid_artist).to be_truthy
        expect(json['artist']).to_not eq(music_json['artist'])
        expect(valid_release_date).to be_truthy
        expect(json['release_date']).to_not eq(music_json['release_date'])
        expect(valid_duration).to be_truthy
        expect(json['duration']).to_not eq(music_json['duration'])
        expect(valid_number_views).to be_truthy
        expect(json['number_views']).to_not eq(music_json['number_views'])
        expect(valid_feat).to be_truthy
        expect(json['feat']).to_not eq(music_json['feat'])
        expect(json['deleted']).to be_nil
        expect(json['user']).to be_nil
        expect(json['created_at']).to_not be_nil
        expect(json['updated_at']).to_not be_nil
        expect(valid_created_at).to be_truthy
        expect(json['updated_at']).to eq(db_music_json['updated_at'])
        expect(json['updated_at']).to_not eq(music_json['updated_at'])
        expect(response).to have_http_status(200)
      end
    end

    context 'put minimal attributes music' do
      let(:music_params) { minimal_attributes_music }
    
      it 'put music' do

        music_json = convert_music_to_json(music)
    
        db_music = Music.find_by(id: json['id'], user: user1)
        db_music_json = convert_music_to_json(db_music)
    
        valid_title = all_equals(
          minimal_attributes_music[:title], 
          db_music_json['title'], 
          json['title']
        )
    
        valid_artist = all_equals(
          minimal_attributes_music[:artist], 
          db_music_json['artist'], 
          json['artist']
        )
    
        valid_release_date = all_equals(
          minimal_attributes_music[:release_date], 
          db_music_json['release_date'], 
          json['release_date']
        )
    
        valid_duration = all_equals(
          minimal_attributes_music[:duration], 
          db_music_json['duration'], 
          json['duration']
        )

        valid_number_views = all_equals(
          music_json['number_views'], 
          db_music_json['number_views'], 
          json['number_views']
        )
    
        valid_feat = all_equals(
          music_json['feat'], 
          db_music_json['feat'], 
          json['feat']
        )
    
        valid_created_at = all_equals(
          music_json['created_at'], 
          db_music_json['created_at'], 
          json['created_at']
        )
    
        expect(json['id']).to eq(music_json['id'])
        expect(valid_title).to be_truthy
        expect(json['title']).to_not eq(music_json['title'])
        expect(valid_artist).to be_truthy
        expect(json['artist']).to_not eq(music_json['artist'])
        expect(valid_release_date).to be_truthy
        expect(json['release_date']).to_not eq(music_json['release_date'])
        expect(valid_duration).to be_truthy
        expect(json['duration']).to_not eq(music_json['duration'])
        expect(valid_number_views).to be_truthy
        expect(valid_feat).to be_truthy
        expect(json['deleted']).to be_nil
        expect(json['user']).to be_nil
        expect(json['created_at']).to_not be_nil
        expect(json['updated_at']).to_not be_nil
        expect(valid_created_at).to be_truthy
        expect(json['updated_at']).to eq(db_music_json['updated_at'])
        expect(json['updated_at']).to_not eq(music_json['updated_at'])
        expect(response).to have_http_status(200)
      end
    end

    context 'put nonexistent music by id' do
      let(:music_id) { 100 }
    
      it 'put music' do
        expect(json['message']).to eq(Messages::MUSIC_NOT_FOUND)
        expect(response).to have_http_status(404)
      end
    end
    
    context 'put deleted music by id' do
      let(:music_id) { deleted_music.id }
    
      it 'put music' do
        expect(json['message']).to eq(Messages::MUSIC_NOT_FOUND)
        expect(response).to have_http_status(404)
      end
    end
    
    context 'put nonexistent music by user' do
      let(:header_user1) { header_user2 }
    
      it 'put music' do
        expect(json['message']).to eq(Messages::MUSIC_NOT_FOUND)
        expect(response).to have_http_status(404)
      end
    end
    
    context 'put music without title field' do
      let(:music_params) { { **minimal_attributes_music, title: '' } }
    
      it 'put music' do
        expect(json['message']).to eq(Messages::TITLE_IS_REQUIRED)
        expect(response).to have_http_status(400)
      end
    end
    
    context 'put music without artist field' do
      let(:music_params) { { **minimal_attributes_music, artist: '' } }
    
      it 'put music' do
        expect(json['message']).to eq(Messages::ARTIST_IS_REQUIRED)
        expect(response).to have_http_status(400)
      end
    end
    
    context 'put music without release date field' do
      let(:music_params) { { **minimal_attributes_music, release_date: '' } }
    
      it 'put music' do
        expect(json['message']).to eq(Messages::RELEASE_DATE_IS_REQUIRED)
        expect(response).to have_http_status(400)
      end
    end
    
    context 'put music without duration field' do
      let(:music_params) { { **minimal_attributes_music, duration: '' } }
    
      it 'put music' do
        expect(json['message']).to eq(Messages::DURATION_IS_REQUIRED)
        expect(response).to have_http_status(400)
      end
    end
    
    context 'put music with release date future' do
      let(:music_params) {
        { 
          **minimal_attributes_music, 
          release_date: (Date.today + 1).to_s 
        } 
      }
    
      it 'put music' do
        expect(json['message']).to eq(Messages::RELEASE_DATE_CANNOT_BE_FUTURE)
        expect(response).to have_http_status(400)
      end
    end
    
    context 'put music wrong release date format' do
      let(:music_params) {
        { 
          **minimal_attributes_music, 
          release_date: minimal_attributes_music[:release_date].gsub('-', '/')
        } 
      }
    
      it 'put music' do
        expect(json['message']).to eq(Messages::WRONG_RELEASE_DATE_FORMAT)
        expect(response).to have_http_status(400)
      end
    end
    
    context 'put music wrong duration format' do
      let(:music_params) {
        { 
          **minimal_attributes_music, 
          duration: minimal_attributes_music[:duration].gsub(':', '/')
        } 
      }
    
      it 'put music' do
        expect(json['message']).to eq(Messages::WRONG_DURATION_FORMAT)
        expect(response).to have_http_status(400)
      end
    end
    
    context 'put music with invalid token' do
      let(:header_user1) { { 'Authorization': 'Bearer 123' } }
    
      it 'put music' do
        expect(json['message']).to eq(Messages::INVALID_TOKEN)
        expect(response).to have_http_status(401)
      end
    end
    
    context 'put music with empty authorization header' do
      let(:header_user1) { { 'Authorization': '' } }
    
      it 'put music' do
        expect(json['message']).to eq(Messages::HEADER_AUTHORIZATION_NOT_PRESENT)
        expect(response).to have_http_status(401)
      end
    end
    
    context 'put music with no token header' do
      let(:header_user1) { { 'Authorization': 'Bearer ' } }
    
      it 'put music' do
        expect(json['message']).to eq(Messages::NO_TOKEN_PROVIDED)
        expect(response).to have_http_status(401)
      end
    end
    
    context 'put music without authorization header' do
      let(:header_user1) { nil }
    
      it 'put music' do
        expect(json['message']).to eq(Messages::HEADER_AUTHORIZATION_NOT_PRESENT)
        expect(response).to have_http_status(401)
      end
    end
    
    context 'put music without bearer authentication scheme' do
      let(:header_user1) { no_bearer_header }
    
      it 'put music' do
        expect(json['message']).to eq(Messages::NO_BEARER_AUTHENTICATION_SCHEME)
        expect(response).to have_http_status(401)
      end
    end

    context 'put music with expired token' do
      let(:header_user1) { expired_token_header }
  
      it 'put music' do
        expect(json['message']).to eq(Messages::TOKEN_EXPIRED)
        expect(response).to have_http_status(401)
      end
    end
  end
end