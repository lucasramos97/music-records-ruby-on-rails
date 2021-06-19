class Music < ApplicationRecord
  validates_presence_of :title, :artist, :release_date, :duration
end
