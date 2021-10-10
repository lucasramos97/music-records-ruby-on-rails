require 'rails_helper'

RSpec.describe 'Post Music', type: :request do
  let!(:users) { create_list(:user, 1) }
  let!(:user1) { users[0] }
  let!(:token_user1) { generate_token(user1.id) }
  let!(:header_user1) { { 'Authorization': "Bearer #{token_user1}" } }
  let!(:no_bearer_header) { { 'Authorization': "Token_user1 #{token_user1}" } }
  
  describe 'POST /musics' do
    let!(:all_attributes_music) {
      {
        title: 'Title Test',
        artist: 'Artist Test',
        release_date: Date.today.to_s,
        duration: Time.new.strftime('%H:%M:%S'),
        number_views: 1,
        feat: true, 
      }
    }
    let!(:minimal_attributes_music) {
      {
        title: 'Title Test',
        artist: 'Artist Test',
        release_date: Date.today.to_s,
        duration: Time.new.strftime('%H:%M:%S'),
      }
    }
    let!(:music_params) { all_attributes_music }

    before { post '/musics', params: music_params, headers: header_user1 }

    context 'post all attributes music' do
      it 'post music' do

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

        expect(valid_title).to be_truthy
        expect(valid_artist).to be_truthy
        expect(valid_release_date).to be_truthy
        expect(valid_duration).to be_truthy
        expect(valid_number_views).to be_truthy
        expect(valid_feat).to be_truthy
        expect(json['deleted']).to be_nil
        expect(json['user']).to be_nil
        expect(json['created_at']).to_not be_nil
        expect(json['updated_at']).to_not be_nil
        expect(json['created_at']).to eq(db_music_json['created_at'])
        expect(json['updated_at']).to eq(db_music_json['updated_at'])
        expect(json['created_at']).to eq(json['updated_at'])
        expect(response).to have_http_status(201)
      end
    end

    context 'post minimal attributes music' do
      let(:music_params) { minimal_attributes_music }

      it 'post music' do

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
          0, 
          db_music_json['number_views'], 
          json['number_views']
        )

        valid_feat = all_equals(
          false, 
          db_music_json['feat'], 
          json['feat']
        )

        expect(valid_title).to be_truthy
        expect(valid_artist).to be_truthy
        expect(valid_release_date).to be_truthy
        expect(valid_duration).to be_truthy
        expect(valid_number_views).to be_truthy
        expect(valid_feat).to be_truthy
        expect(json['deleted']).to be_nil
        expect(json['user']).to be_nil
        expect(json['created_at']).to_not be_nil
        expect(json['updated_at']).to_not be_nil
        expect(json['created_at']).to eq(db_music_json['created_at'])
        expect(json['updated_at']).to eq(db_music_json['updated_at'])
        expect(json['created_at']).to eq(json['updated_at'])
        expect(response).to have_http_status(201)
      end
    end

    context 'post music without title field' do
      let(:music_params) { { **minimal_attributes_music, title: '' } }

      it 'post music' do
        expect(json['message']).to eq(Messages::TITLE_IS_REQUIRED)
        expect(response).to have_http_status(400)
      end
    end

    context 'post music without artist field' do
      let(:music_params) { { **minimal_attributes_music, artist: '' } }

      it 'post music' do
        expect(json['message']).to eq(Messages::ARTIST_IS_REQUIRED)
        expect(response).to have_http_status(400)
      end
    end

    context 'post music without release date field' do
      let(:music_params) { { **minimal_attributes_music, release_date: '' } }

      it 'post music' do
        expect(json['message']).to eq(Messages::RELEASE_DATE_IS_REQUIRED)
        expect(response).to have_http_status(400)
      end
    end

    context 'post music without duration field' do
      let(:music_params) { { **minimal_attributes_music, duration: '' } }

      it 'post music' do
        expect(json['message']).to eq(Messages::DURATION_IS_REQUIRED)
        expect(response).to have_http_status(400)
      end
    end

    context 'post music with release date future' do
      let(:music_params) {
        { 
          **minimal_attributes_music, 
          release_date: (Date.today + 1).to_s 
        } 
      }

      it 'post music' do
        expect(json['message']).to eq(Messages::RELEASE_DATE_CANNOT_BE_FUTURE)
        expect(response).to have_http_status(400)
      end
    end

    context 'post music wrong release date format' do
      let(:music_params) {
        { 
          **minimal_attributes_music, 
          release_date: minimal_attributes_music[:release_date].gsub('-', '/')
        } 
      }

      it 'post music' do
        expect(json['message']).to eq(Messages::WRONG_RELEASE_DATE_FORMAT)
        expect(response).to have_http_status(400)
      end
    end

    context 'post music wrong duration format' do
      let(:music_params) {
        { 
          **minimal_attributes_music, 
          duration: minimal_attributes_music[:duration].gsub(':', '/')
        } 
      }

      it 'post music' do
        expect(json['message']).to eq(Messages::WRONG_DURATION_FORMAT)
        expect(response).to have_http_status(400)
      end
    end
    
    context 'post music with invalid token' do
      let(:header_user1) { { 'Authorization': 'Bearer 123' } }
  
      it 'post music' do
        expect(json['message']).to eq(Messages::INVALID_TOKEN)
        expect(response).to have_http_status(401)
      end
    end
  
    context 'post music with empty authorization header' do
      let(:header_user1) { { 'Authorization': '' } }
  
      it 'post music' do
        expect(json['message']).to eq(Messages::HEADER_AUTHORIZATION_NOT_PRESENT)
        expect(response).to have_http_status(401)
      end
    end
  
    context 'post music with no token header' do
      let(:header_user1) { { 'Authorization': 'Bearer ' } }
  
      it 'post music' do
        expect(json['message']).to eq(Messages::NO_TOKEN_PROVIDED)
        expect(response).to have_http_status(401)
      end
    end
  
    context 'post music without authorization header' do
      let(:header_user1) { nil }
  
      it 'post music' do
        expect(json['message']).to eq(Messages::HEADER_AUTHORIZATION_NOT_PRESENT)
        expect(response).to have_http_status(401)
      end
    end

    context 'post music without bearer authentication scheme' do
      let(:header_user1) { no_bearer_header }
  
      it 'post music' do
        expect(json['message']).to eq(Messages::NO_BEARER_AUTHENTICATION_SCHEME)
        expect(response).to have_http_status(401)
      end
    end
  end
end