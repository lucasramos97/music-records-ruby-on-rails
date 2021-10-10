module RequestSpecHelper
  
  def json
    JSON.parse(response.body)
  end

  def generate_token(user_id)
    JsonWebToken.encode(user_id: user_id)
  end

  def generate_expired_token(user_id)
    token = JsonWebToken.encode({ user_id: user_id }, (Time.now.to_i - 10))
    { 'Authorization': "Bearer #{token}" }
  end

  def all_equals(object, *search_objects)

    if object.nil?
      return false
    end

    s_object = object.to_s

    search_objects.each { |o| 
      if s_object != o.to_s
        return false
      end
    }

    return true
  end

  def convert_music_to_json(music)
    content = music.as_json(except: [:deleted, :user_id])
    JSON.parse(content.to_json)
  end

  def convert_user_to_json(user)
    content = user.to_json
    JSON.parse(content.gsub('password_digest', 'password'))
  end

  def match_date(date)
    /\d{4}-\d{2}-\d{2}/.match(date)
  end

  def match_time(time)
    /\d{2}:\d{2}:\d{2}/.match(time)
  end

  def match_date_time(date_time)
    /\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}.\d{3}/.match(date_time)
  end
end