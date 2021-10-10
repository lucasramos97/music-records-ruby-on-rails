class User < ApplicationRecord
  has_secure_password
  has_many :musics, dependent: :destroy
  validates_presence_of :username, :email, :password_digest

  def created_at
    
    if not super
      return nil
    end

    return super.strftime("%Y-%m-%d %H:%M:%S.%L")
  end

  def updated_at
    
    if not super
      return nil
    end

    return super.strftime("%Y-%m-%d %H:%M:%S.%L")
  end
end
