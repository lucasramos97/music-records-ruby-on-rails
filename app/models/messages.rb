
class Messages

  # User Messages
  USERNAME_IS_REQUIRED = 'Username is required!'
  EMAIL_INVALID = 'E-mail invalid!'
  EMAIL_IS_REQUIRED = 'E-mail is required!'
  PASSWORD_IS_REQUIRED = 'Password is required!'

  # Music Messages
  ID_IS_REQUIRED = 'Id is required!'
  TITLE_IS_REQUIRED = 'Title is required!'
  ARTIST_IS_REQUIRED = 'Artist is required!'
  RELEASE_DATE_IS_REQUIRED = 'Release Date is required!'
  DURATION_IS_REQUIRED = 'Duration is required!'
  MUSIC_NOT_FOUND = 'Music not found!'
  RELEASE_DATE_CANNOT_BE_FUTURE = 'Release Date cannot be future!'
  WRONG_RELEASE_DATE_FORMAT = 'Wrong Release Date format, try yyyy-MM-dd!'
  WRONG_DURATION_FORMAT = 'Wrong Duration format, try HH:mm:ss!'

  # Authorization Messages
  HEADER_AUTHORIZATION_NOT_PRESENT = 'Header Authorization not present!'
  NO_BEARER_AUTHENTICATION_SCHEME = 'No Bearer HTTP authentication scheme!'
  NO_TOKEN_PROVIDED = 'No token provided!'
  INVALID_TOKEN = 'Invalid token!'
  TOKEN_EXPIRED = 'Log in again, your token has expired!'

  def self.get_email_already_registered(email)
    "The #{email} e-mail has already been registered!"
  end

  def self.get_user_not_found_by_email(email)
    "User not found by e-mail: #{email}!"
  end

  def self.get_password_does_not_match_with_email(email)
    "Password does not match with email: #{email}!"
  end
end