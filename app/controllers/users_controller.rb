class UsersController < ApplicationController
  before_action :verify_login, only: [:login]

  def login
    res = AuthenticateUser.new(user_params[:email], user_params[:password]).call
    json_response(res)
  end

  private

  def user_params
    params.permit(:username, :email, :password)
  end

  def verify_login
    params.require(:email)
    if not URI::MailTo::EMAIL_REGEXP.match?(params[:email])
      raise(ExceptionHandler::ParameterInvalid, 'E-mail invalid!')
    end
    params.require(:password)
  end

end
