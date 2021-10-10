class AuthorizeApiRequest
  def initialize(headers = {})
    @headers = headers
  end

  def call
    {
      user: user
    }
  end

  private

  attr_reader :headers

  def user
    @user ||= User.find(decoded_auth_token[:user_id]) if decoded_auth_token
  end

  def decoded_auth_token
    @decoded_auth_token ||= JsonWebToken.decode(http_auth_header)
  end

  def http_auth_header

    authorization = headers['Authorization']
    if authorization.blank?
      raise(ExceptionHandler::AuthenticationError, Messages::HEADER_AUTHORIZATION_NOT_PRESENT)
    end

    if not authorization.start_with?('Bearer ')
      raise(ExceptionHandler::AuthenticationError, Messages::NO_BEARER_AUTHENTICATION_SCHEME)
    end

    token = authorization.split('Bearer ').last
    if not token
      raise(ExceptionHandler::AuthenticationError, Messages::NO_TOKEN_PROVIDED)
    end

    return token
  end
end