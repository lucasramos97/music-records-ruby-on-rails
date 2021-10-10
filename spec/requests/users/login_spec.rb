require 'rails_helper'

SECRET_KEY = Rails.application.secrets.secret_key_base

RSpec.describe 'Login', type: :request do
  describe 'POST /login' do
    let!(:users) { create_list(:user, 1) }
    let!(:user1) { users[0] }
    let!(:all_attributes_login) {
      {
        email: user1.email,
        password: '123',
      }
    }
    let!(:login_params) { all_attributes_login }

    before { post '/login', params: login_params }
    
    context 'login' do
      it 'login' do
        expect(json['token']).to_not be_blank
        expect(json['username']).to eq(user1.username)
        expect(json['email']).to eq(user1.email)
        expect(json['password']).to be_nil
        expect(response).to have_http_status(200)
      end
    end

    context 'token lasts 24 hours' do
      it 'login' do
        
        payload = JWT.decode(json['token'], SECRET_KEY, true, { algorithm: 'HS256' })[0]
        
        expect(payload['exp']).to eq(24.hours.from_now.to_i)
      end
    end

    context 'login without email field' do
      let(:login_params) { { **all_attributes_login, email: '' } }

      it 'login' do
        expect(json['message']).to eq(Messages::EMAIL_IS_REQUIRED)
        expect(response).to have_http_status(400)
      end
    end

    context 'login without password field' do
      let(:login_params) { { **all_attributes_login, password: '' } }

      it 'login' do
        expect(json['message']).to eq(Messages::PASSWORD_IS_REQUIRED)
        expect(response).to have_http_status(400)
      end
    end

    context 'login with invalid email' do
      let(:login_params) { { **all_attributes_login, email: 'test' } }

      it 'login' do
        expect(json['message']).to eq(Messages::EMAIL_INVALID)
        expect(response).to have_http_status(400)
      end
    end

    context 'login with nonexistent email' do
      let(:login_params) { { **all_attributes_login, email: 'user2@email.com' } }

      it 'login' do

        expected_message = Messages.get_user_not_found_by_email(login_params[:email])

        expect(json['message']).to eq(expected_message)
        expect(response).to have_http_status(401)
      end
    end

    context 'login with non matching password' do
      let(:login_params) { { **all_attributes_login, password: '321' } }

      it 'login' do

        expected_message = Messages.get_password_does_not_match_with_email(all_attributes_login[:email])

        expect(json['message']).to eq(expected_message)
        expect(response).to have_http_status(401)
      end
    end
  end
end