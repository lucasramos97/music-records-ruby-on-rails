class UsersController < ApplicationController
  skip_before_action :authorize_request, only: [:login, :create]
  before_action :verify_create, only: :create
  before_action :verify_login, only: [:login, :create]

  def login
    res = AuthenticateUser.new(user_params[:email], user_params[:password]).call
    json_response(res)
  end

  def create
    @user = User.create!(user_params)
    json_response(@user, :created)
  end

  private

  def user_params
    params.permit(:username, :email, :password)
  end

  def verify_create
    params.require(:username)
  end

  def verify_login
    params.require(:email)
    if not URI::MailTo::EMAIL_REGEXP.match?(params[:email])
      raise(ExceptionHandler::ParameterInvalid, 'E-mail invalid!')
    end
    params.require(:password)
  end

end
