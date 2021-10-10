class UsersController < ApplicationController
  skip_before_action :authorize_request, only: [:create, :login]
  before_action :verify_user_fields, only: [:create]
  before_action :verify_login_fields, only: [:login]

  def create
    @db_user = User.create!(user_params)
    user = {
      id: @db_user.id,
      username: @db_user.username,
      email: @db_user.email,
      password: @db_user.password_digest,
      created_at: @db_user.created_at,
      updated_at: @db_user.updated_at
    }
    json_response(user, :created)
  end

  def login
    result = AuthenticateUser.new(user_params[:email], user_params[:password]).call
    json_response(result)
  end

  private

  EMAIL_REGEX = /^(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})$/i

  def user_params
    params.permit(:username, :email, :password)
  end

  def verify_user_fields

    if user_params[:username].blank?
      raise(ExceptionHandler::FieldError, Messages::USERNAME_IS_REQUIRED)
    end

    verify_login_fields

  end

  def verify_login_fields

    if user_params[:email].blank?
      raise(ExceptionHandler::FieldError, Messages::EMAIL_IS_REQUIRED)
    end

    if EMAIL_REGEX.match(user_params[:email]).nil?
      raise(ExceptionHandler::FieldError, Messages::EMAIL_INVALID)
    end

    if user_params[:password].blank?
      raise(ExceptionHandler::FieldError, Messages::PASSWORD_IS_REQUIRED)
    end
  end

end
