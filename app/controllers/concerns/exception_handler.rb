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

    rescue_from ActiveRecord::RecordNotUnique do |e|
      email = ''
      if e.binds and e.binds.length > 1
        email = JSON.parse(e.binds[1].to_json)['value']
      else
        email = e.sql.split(',')[5].strip.gsub("'", "")
      end
      message = Messages.get_email_already_registered(email)
      json_response({ message: message }, :bad_request)
    end
  end
end