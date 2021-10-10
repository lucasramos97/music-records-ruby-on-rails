require 'rails_helper'

RSpec.describe 'Create User', type: :request do
  describe 'POST /users' do
    let!(:all_attributes_user) {
      {
        username: 'user1',
        email: 'user1@email.com',
        password: '123',
      }
    }
    let!(:user_params) { all_attributes_user }

    before { post '/users', params: user_params }
    
    context 'create user' do
      it 'create user' do

        db_user = User.find_by(id: json['id'])
        db_user_json = convert_user_to_json(db_user)

        valid_username = all_equals(
          all_attributes_user[:username], 
          db_user_json['username'], 
          json['username']
        )

        valid_email = all_equals(
          all_attributes_user[:email], 
          db_user_json['email'], 
          json['email']
        )

        expect(valid_username).to be_truthy
        expect(valid_email).to be_truthy
        expect(db_user_json['password']).to_not eq(all_attributes_user['password'])
        expect(json['password']).to eq(db_user_json['password'])
        expect(json['created_at']).to_not be_nil
        expect(json['updated_at']).to_not be_nil
        expect(json['created_at']).to eq(db_user_json['created_at'])
        expect(json['updated_at']).to eq(db_user_json['updated_at'])
        expect(json['created_at']).to eq(json['updated_at'])
        expect(response).to have_http_status(201)
      end
    end

    context 'create user without username field' do
      let(:user_params) { { **all_attributes_user, username: '' } }

      it 'create user' do
        expect(json['message']).to eq(Messages::USERNAME_IS_REQUIRED)
        expect(response).to have_http_status(400)
      end
    end

    context 'create user without email field' do
      let(:user_params) { { **all_attributes_user, email: '' } }

      it 'create user' do
        expect(json['message']).to eq(Messages::EMAIL_IS_REQUIRED)
        expect(response).to have_http_status(400)
      end
    end

    context 'create user without password field' do
      let(:user_params) { { **all_attributes_user, password: '' } }

      it 'create user' do
        expect(json['message']).to eq(Messages::PASSWORD_IS_REQUIRED)
        expect(response).to have_http_status(400)
      end
    end

    context 'create user with invalid email' do
      let(:user_params) { { **all_attributes_user, email: 'test' } }

      it 'create user' do
        expect(json['message']).to eq(Messages::EMAIL_INVALID)
        expect(response).to have_http_status(400)
      end
    end

    context 'create user with existent email' do
      before { post '/users', params: user_params }

      it 'create user' do

        expected_message = Messages.get_email_already_registered(all_attributes_user[:email])

        expect(json['message']).to eq(expected_message)
        expect(response).to have_http_status(400)
      end
    end
  end
end