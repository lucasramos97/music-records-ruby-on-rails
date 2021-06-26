module ExceptionHandler extend ActiveSupport::Concern
  included do
    
    rescue_from ActiveRecord::RecordNotFound do |e|
      json_response({ message: "Music not found by id: #{e.id}" }, :not_found)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      json_response(format_record_invalid_message(e.message), :bad_request)
    end

    private

    def format_record_invalid_message(message)
      field = message.split('Validation failed: ')[1].split(" can't be blank")[0]

      return { message: "#{field} is required!" }
    end
  end
end