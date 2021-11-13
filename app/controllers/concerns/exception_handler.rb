module ExceptionHandler extend ActiveSupport::Concern
  class FieldError < StandardError; end
  class AuthenticationError < StandardError; end
  
  included do
    
    rescue_from ActiveRecord::RecordNotFound do |e|
      json_response({ message: Messages::MUSIC_NOT_FOUND }, :not_found)
    end

    rescue_from ExceptionHandler::FieldError do |e|
      json_response({ message: e.message }, :bad_request)
    end

    rescue_from ExceptionHandler::AuthenticationError do |e|
      json_response({ message: e.message }, :unauthorized)
    end
  end
end