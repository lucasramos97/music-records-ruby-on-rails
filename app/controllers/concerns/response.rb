module Response
  def json_response(object = nil, status = :ok)
    
    if not object
      return render status: status
    end
    
    content = object.as_json(except: [:deleted, :user_id])
    return render json: content, status: status
  end
end