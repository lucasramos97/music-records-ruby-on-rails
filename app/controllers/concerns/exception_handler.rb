module ExceptionHandler extend ActiveSupport::Concern
  class ParameterInvalid < StandardError; end
  class AuthenticationError < StandardError; end
  
  included do
    rescue_from ActiveRecord::RecordNotFound do |e|
      json_response({ message: 'Music not found!' }, :not_found)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      json_response(record_invalid_message(e.record.errors), :bad_request)
    end

    rescue_from ActionController::ParameterMissing do |e|
      json_response(parameter_missing_message(e.param), :bad_request)
    end

    rescue_from ExceptionHandler::ParameterInvalid do |e|
      json_response({ message: e.message }, :bad_request)
    end

    rescue_from ExceptionHandler::AuthenticationError do |e|
      json_response({ message: e.message }, :unauthorized)
    end

    private
    
    def record_invalid_message(errors)
      if errors.has_key?(:title)
        return { message: 'Title is required!' }
      elsif errors.has_key?(:artist)
        return { message: 'Artist is required!' }
      elsif errors.has_key?(:release_date)
        return { message: 'Release Date is required!' }
      elsif errors.has_key?(:duration)
        return { message: 'Duration is required!' }
      else
        return { message: '!' }
      end
    end

    def parameter_missing_message(param)
      if param == :email
        return { message: 'E-mail is required!' }
      elsif param == :password
        return { message: 'Password is required!' }
      elsif param == :_json or param == :id
        return { message: 'Id is required to all musics!' }
      else
        puts param
        return { message: '!' }
      end
    end
  end
end