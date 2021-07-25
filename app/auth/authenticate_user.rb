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
      raise(ExceptionHandler::AuthenticationError, "User not found by e-mail: #{email}!")
    end
    
    if not user.authenticate(password)
      raise(ExceptionHandler::AuthenticationError, 'Password invalid!')
    end

    return user
  end
end