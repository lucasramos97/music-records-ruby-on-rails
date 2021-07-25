require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  let!(:user) { create(:user) }
  let(:headers) { { 'Authorization': token_generator(user.id) } }
  let(:login) { { email: user.email, password: user.password } }

  describe 'POST /login' do
    before { post '/login', params: login, headers: headers }

    context 'with valid credentials' do
      it 'return authentication datas' do
        expect(json['username']).to eq(user.username)
        expect(json['email']).to eq(user.email)
        expect(json['token']).not_to be_nil
        expect(response).to have_http_status(200)
      end
    end

    context 'when the request does not have the email field' do
      let(:login) { { password: user.password } }

      it 'return authentication datas' do
        expect(json['message']).to eq('E-mail is required!')
        expect(response).to have_http_status(400)
      end
    end

    context 'when the request does not have the password field' do
      let(:login) { { email: user.email } }

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
end