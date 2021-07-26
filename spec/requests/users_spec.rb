require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  let!(:user) { create(:user) }
  let(:login) { { email: user.email, password: user.password } }
  let(:user_attributes) { { username: 'test', email: 'test@email.com', password: '123' } }

  describe 'POST /login' do
    before { post '/login', params: login }

    context 'with valid credentials' do
      it 'return authentication datas' do
        expect(json['username']).to eq(user.username)
        expect(json['email']).to eq(user.email)
        expect(json['token']).not_to be_nil
        expect(response).to have_http_status(200)
      end
    end

    context 'when the request does not have the email field' do
      let(:login) { { email: '', password: user.password } }

      it 'return authentication datas' do
        expect(json['message']).to eq('E-mail is required!')
        expect(response).to have_http_status(400)
      end
    end

    context 'when the request does not have the password field' do
      let(:login) { { email: user.email, password: '' } }

      it 'return authentication datas' do
        expect(json['message']).to eq('Password is required!')
        expect(response).to have_http_status(400)
      end
    end

    context 'when the request have invalid email field' do
      let(:login) { { email: 'test', password: user.password } }

      it 'return authentication datas' do
        expect(json['message']).to eq('E-mail invalid!')
        expect(response).to have_http_status(400)
      end
    end

    context 'when the request have non-existent e-mail' do
      let(:login) { { email: 'test@email.com', password: user.password } }

      it 'return authentication datas' do
        expect(json['message']).to eq("User not found by e-mail: #{login[:email]}!")
        expect(response).to have_http_status(401)
      end
    end

    context 'when the request have invalid password' do
      let(:login) { { email: user.email, password: '123' } }

      it 'return authentication datas' do
        expect(json['message']).to eq('Password invalid!')
        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'POST /users' do
    before { post '/users', params: user_attributes }

    context 'with valid credentials' do
      it 'create user' do
        expect(json['username']).to eq(user_attributes[:username])
        expect(json['email']).to eq(user_attributes[:email])
        expect(json['password_digest']).to be
        expect(json['password_digest']).not_to eq(user_attributes[:password])
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request does not have the username field' do
      let(:user_attributes) { { username: '', email: 'test@email.com', password: '123' } }

      it 'create user' do
        expect(json['message']).to eq('Username is required!')
        expect(response).to have_http_status(400)
      end
    end

    context 'when the request does not have the email field' do
      let(:user_attributes) { { username: 'test', email: '', password: '123' } }

      it 'create user' do
        expect(json['message']).to eq('E-mail is required!')
        expect(response).to have_http_status(400)
      end
    end

    context 'when the request does not have the password field' do
      let(:user_attributes) { { username: 'test', email: 'test@email.com', password: '' } }

      it 'create user' do
        expect(json['message']).to eq('Password is required!')
        expect(response).to have_http_status(400)
      end
    end

    context 'when the request have invalid email field' do
      let(:user_attributes) { { username: 'test', email: 'test', password: '' } }

      it 'create user' do
        expect(json['message']).to eq('E-mail invalid!')
        expect(response).to have_http_status(400)
      end
    end

    context 'when the request have existent email field' do
      let(:user_attributes) { { username: 'test', email: user.email, password: '123' } }

      it 'create user' do
        expect(json['message']).to eq("The #{user.email} e-mail has already been registered!")
        expect(response).to have_http_status(400)
      end
    end
  end
end