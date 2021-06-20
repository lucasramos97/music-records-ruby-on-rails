module ExceptionHandler extend ActiveSupport::Concern
  included do
    
    rescue_from ActiveRecord::RecordNotFound do |e|
      json_response({ message: "Music not found by id: #{e.id}" }, :not_found)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      json_response({ message: e.message }, :unprocessable_entity)
    end
  end
end