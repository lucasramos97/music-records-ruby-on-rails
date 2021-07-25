class User < ApplicationRecord
  has_secure_password
  has_many :musics, dependent: :destroy
  validates_presence_of :username, :email, :password_digest
end
