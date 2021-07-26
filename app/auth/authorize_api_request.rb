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
    if not authorization
      raise(ExceptionHandler::AuthenticationError, 'Header Authorization not present!')
    end

    if not authorization.start_with?('Bearer ')
      raise(ExceptionHandler::AuthenticationError, 'No Bearer HTTP authentication scheme!')
    end

    token = authorization.split('Bearer ').last
    if not token
      raise(ExceptionHandler::AuthenticationError, 'No token provided!')
    end

    return token
  end
end