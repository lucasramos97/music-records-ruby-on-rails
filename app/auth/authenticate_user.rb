class AuthenticateUser
  
  def initialize(email, password)
    @email = email
    @password = password
  end

  def call
    user = get_user
    token = JsonWebToken.encode(user_id: user.id)
    {
      token: token,
      username: user.username,
      email: user.email
    }
  end

  private

  attr_reader :email, :password

  def get_user
    user = User.find_by(email: email)
    
    if not user
      message = Messages.get_user_not_found_by_email(email)
      raise(ExceptionHandler::AuthenticationError, message)
    end
    
    if not user.authenticate(password)
      message = Messages.get_password_does_not_match_with_email(email)
      raise(ExceptionHandler::AuthenticationError, message)
    end

    return user
  end
end