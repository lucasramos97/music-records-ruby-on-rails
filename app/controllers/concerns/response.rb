module Response
  def json_response(object = nil, status = :ok)
    if not object
      return render status: status
    end
    return render json: object, status: status
  end
end